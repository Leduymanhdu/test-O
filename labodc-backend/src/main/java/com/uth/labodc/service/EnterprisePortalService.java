package com.uth.labodc.service;

import com.uth.labodc.dto.enterprise.*;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.Mentor;
import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.MentorRepository;
import com.uth.labodc.repository.ProjectRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class EnterprisePortalService {

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    private final MentorRepository mentorRepository;
    private final ProjectRepository projectRepository;
    private final ProjectValidationService projectValidationService;

    public EnterpriseDashboardSummaryDTO getDashboardSummary(User user) {
        long enterpriseId = requireEnterpriseId(user);
        Map<String, Object> params = Map.of("enterpriseId", enterpriseId);

        String sql = """
                SELECT
                  COUNT(*) AS total_projects,
                  SUM(CASE WHEN status IN ('IN_PROGRESS', 'RECRUITING') THEN 1 ELSE 0 END) AS active_projects,
                  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_projects
                FROM projects
                WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                """;

        EnterpriseDashboardSummaryDTO summary = jdbcTemplate.query(sql, params, rs -> {
            if (!rs.next()) {
                return EnterpriseDashboardSummaryDTO.builder()
                        .totalProjects(0)
                        .activeProjects(0)
                        .completedProjects(0)
                        .totalSpent(0)
                        .build();
            }
            return EnterpriseDashboardSummaryDTO.builder()
                    .totalProjects(rs.getLong("total_projects"))
                    .activeProjects(rs.getLong("active_projects"))
                    .completedProjects(rs.getLong("completed_projects"))
                    .totalSpent(0)
                    .build();
        });

        String spentSql = """
                SELECT COALESCE(SUM(amount), 0) AS total_spent
                FROM payments
                WHERE enterprise_id = :enterpriseId AND status = 'COMPLETED'
                """;
        Double totalSpent = jdbcTemplate.query(spentSql, params, rs -> rs.next() ? rs.getDouble("total_spent") : 0d);
        summary.setTotalSpent(totalSpent != null ? totalSpent : 0d);
        summary.setNotifications(loadMentorNotifications(enterpriseId));

        return summary;
    }

    private List<String> loadMentorNotifications(long enterpriseId) {
        String sql = """
                SELECT COALESCE(mi.responded_at, mi.created_at) AS event_time, mi.status, m.full_name, p.title
                FROM mentor_invitations mi
                JOIN projects p ON p.id = mi.project_id
                JOIN mentors m ON m.id = mi.mentor_id
                WHERE p.enterprise_id = :enterpriseId
                  AND p.deleted_at IS NULL
                  AND mi.status IN ('ACCEPTED', 'REJECTED')
                ORDER BY event_time DESC
                LIMIT 5
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), (rs, rowNum) -> {
            String mentorName = rs.getString("full_name");
            String title = rs.getString("title");
            String status = rs.getString("status");
            if ("REJECTED".equalsIgnoreCase(status)) {
                return "Mentor " + mentorName + " đã từ chối lời mời cho dự án \"" + title + "\".";
            }
            return "Mentor " + mentorName + " đã chấp nhận lời mời cho dự án \"" + title + "\".";
        });
    }

    public List<EnterpriseRecentProjectDTO> getRecentProjects(User user, int limit) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT id, title, progress_percentage, current_members_count, status
                FROM projects
                WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                ORDER BY created_at DESC
                LIMIT :limit
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId, "limit", limit),
                (rs, rowNum) -> EnterpriseRecentProjectDTO.builder()
                        .id(rs.getLong("id"))
                        .name(rs.getString("title"))
                        .progress(rs.getInt("progress_percentage"))
                        .members(rs.getInt("current_members_count"))
                        .status(rs.getString("status"))
                        .build());
    }

    public EnterpriseProjectSummaryDTO getProjectSummary(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT
                  COUNT(*) AS total_projects,
                  SUM(CASE WHEN status IN ('RECRUITING', 'IN_PROGRESS') THEN 1 ELSE 0 END) AS in_progress,
                  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
                  COALESCE(SUM(budget), 0) AS total_budget
                FROM projects
                WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), rs -> {
            if (!rs.next()) {
                return EnterpriseProjectSummaryDTO.builder()
                        .total(0).inProgress(0).completed(0).totalBudget(0)
                        .build();
            }
            return EnterpriseProjectSummaryDTO.builder()
                    .total(rs.getLong("total_projects"))
                    .inProgress(rs.getLong("in_progress"))
                    .completed(rs.getLong("completed"))
                    .totalBudget(rs.getDouble("total_budget"))
                    .build();
        });
    }

    public List<EnterpriseProjectItemDTO> getProjects(User user, String status) {
        long enterpriseId = requireEnterpriseId(user);
        String base = """
                SELECT p.id, p.title, p.budget, p.progress_percentage, p.status,
                       COALESCE(spent.total_spent, 0) AS spent,
                       p.current_members_count,
                       p.start_date,
                       p.end_date
                FROM projects p
                LEFT JOIN (
                    SELECT project_id, SUM(amount) AS total_spent
                    FROM payments
                    WHERE status = 'COMPLETED'
                    GROUP BY project_id
                ) spent ON spent.project_id = p.id
                WHERE p.enterprise_id = :enterpriseId AND p.deleted_at IS NULL
                """;
        StringBuilder sql = new StringBuilder(base);
        Map<String, Object> params = new java.util.HashMap<>();
        params.put("enterpriseId", enterpriseId);
        if (status != null && !status.equalsIgnoreCase("ALL")) {
            sql.append(" AND p.status = :status");
            params.put("status", status);
        }
        sql.append(" ORDER BY p.created_at DESC");

        return jdbcTemplate.query(sql.toString(), params, (rs, rowNum) -> EnterpriseProjectItemDTO.builder()
                .key(String.valueOf(rs.getLong("id")))
                .name(rs.getString("title"))
                .budget(rs.getDouble("budget"))
                .spent(rs.getDouble("spent"))
                .progress(rs.getInt("progress_percentage"))
                .status(rs.getString("status"))
                .members(rs.getObject("current_members_count") != null ? rs.getInt("current_members_count") : null)
                .startDate(rs.getDate("start_date") != null ? rs.getDate("start_date").toString() : null)
                .endDate(rs.getDate("end_date") != null ? rs.getDate("end_date").toString() : null)
                .build());
    }

    public List<EnterpriseMentorOptionDTO> getMentors(User user) {
        requireEnterpriseId(user);
        return mentorRepository.findAll().stream()
                .filter(m -> m.getAvailable() == null || m.getAvailable())
                .map(this::toMentorOption)
                .toList();
    }

    public void assignMentor(User user, long projectId, Long mentorId, String message) {
        long enterpriseId = requireEnterpriseId(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (!project.getEnterpriseId().equals(enterpriseId)) {
            throw new ResourceNotFoundException("Project not found for enterprise");
        }
        if (project.getMentorId() != null) {
            throw new IllegalStateException("Project already has a mentor");
        }
        if (project.getStatus() != ProjectStatus.RECRUITING) {
            throw new IllegalStateException("Project is not recruiting yet");
        }
        if (mentorId == null) {
            throw new IllegalArgumentException("Missing mentorId");
        }

        projectValidationService.assignMentor(projectId, mentorId, message);
    }

    public void startProject(User user, long projectId) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT status, current_members_count
                FROM projects
                WHERE id = :projectId AND enterprise_id = :enterpriseId AND deleted_at IS NULL
                """;
        List<ProjectStartMeta> rows = jdbcTemplate.query(sql, Map.of("projectId", projectId, "enterpriseId", enterpriseId),
                (rs, rowNum) -> new ProjectStartMeta(rs.getString("status"),
                        rs.getObject("current_members_count") != null ? rs.getInt("current_members_count") : 0));
        if (rows.isEmpty()) {
            throw new ResourceNotFoundException("Project not found for enterprise");
        }
        ProjectStartMeta meta = rows.get(0);
        if (!"RECRUITING".equalsIgnoreCase(meta.status())) {
            throw new IllegalStateException("Chỉ dự án đang tuyển mới có thể bắt đầu");
        }
        if (meta.members() < 1) {
            throw new IllegalStateException("Cần ít nhất 1 thành viên để bắt đầu dự án");
        }

        jdbcTemplate.update("""
                        UPDATE projects
                        SET status = 'IN_PROGRESS',
                            actual_start_date = COALESCE(actual_start_date, CURRENT_DATE),
                            updated_at = NOW()
                        WHERE id = :projectId AND enterprise_id = :enterpriseId
                        """,
                Map.of("projectId", projectId, "enterpriseId", enterpriseId));
    }

    public void updateProject(User user, long projectId, UpdateEnterpriseProjectRequest request) {
        long enterpriseId = requireEnterpriseId(user);
        ProjectMeta meta = requireEnterpriseProject(projectId, enterpriseId);
        if (!"PENDING_VALIDATION".equalsIgnoreCase(meta.status())) {
            throw new IllegalStateException("Chỉ dự án chờ duyệt mới được chỉnh sửa");
        }

        String objectivesJson = null;
        if (request.getObjectives() != null) {
            try {
                objectivesJson = objectMapper.writeValueAsString(request.getObjectives());
            } catch (JsonProcessingException e) {
                throw new IllegalArgumentException("Không thể lưu mục tiêu dự án");
            }
        }

        String sql = """
                UPDATE projects
                SET title = COALESCE(:title, title),
                    description = COALESCE(:description, description),
                    objectives = COALESCE(:objectives, objectives),
                    requirements = COALESCE(:requirements, requirements),
                    start_date = COALESCE(:startDate, start_date),
                    end_date = COALESCE(:endDate, end_date),
                    budget = COALESCE(:budget, budget),
                    number_of_students = COALESCE(:numberOfStudents, number_of_students),
                    allow_applications = COALESCE(:allowApplications, allow_applications),
                    updated_at = NOW()
                WHERE id = :projectId AND enterprise_id = :enterpriseId
                """;

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("projectId", projectId)
                .addValue("enterpriseId", enterpriseId)
                .addValue("title", request.getName())
                .addValue("description", request.getDescription())
                .addValue("objectives", objectivesJson)
                .addValue("requirements", request.getRequirements())
                .addValue("startDate", request.getStartDate())
                .addValue("endDate", request.getEndDate())
                .addValue("budget", request.getBudget())
                .addValue("numberOfStudents", request.getRequiredTalents())
                .addValue("allowApplications", request.getAllowApplications());

        jdbcTemplate.update(sql, params);

        if (request.getTechnologies() != null) {
            jdbcTemplate.update("DELETE FROM project_technologies WHERE project_id = :projectId",
                    Map.of("projectId", projectId));
            insertTechnologies(projectId, request.getTechnologies());
        }

        if (request.getRequiredSkills() != null) {
            jdbcTemplate.update("DELETE FROM project_skill_requirements WHERE project_id = :projectId",
                    Map.of("projectId", projectId));
            insertSkills(projectId, request.getRequiredSkills());
        }
    }

    public void deleteProject(User user, long projectId) {
        long enterpriseId = requireEnterpriseId(user);
        ProjectMeta meta = requireEnterpriseProject(projectId, enterpriseId);
        if (!"PENDING_VALIDATION".equalsIgnoreCase(meta.status())) {
            throw new IllegalStateException("Chỉ dự án chờ duyệt mới được xóa");
        }
        jdbcTemplate.update("""
                        UPDATE projects SET deleted_at = NOW()
                        WHERE id = :projectId AND enterprise_id = :enterpriseId
                        """,
                Map.of("projectId", projectId, "enterpriseId", enterpriseId));
    }

    public EnterpriseProposalSummaryDTO getProposalSummary(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT
                  COUNT(*) AS total,
                  SUM(CASE WHEN proposal_status = 'PENDING' THEN 1 ELSE 0 END) AS pending,
                  SUM(CASE WHEN proposal_status = 'APPROVED' THEN 1 ELSE 0 END) AS approved,
                  COALESCE(SUM(budget), 0) AS total_budget
                FROM (
                  SELECT budget,
                           CASE
                             WHEN status = 'REJECTED' THEN 'REJECTED'
                             WHEN validated = 'approved' OR status IN ('VALIDATED', 'RECRUITING', 'IN_PROGRESS', 'COMPLETED') THEN 'APPROVED'
                             ELSE 'PENDING'
                           END AS proposal_status
                  FROM projects
                  WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                ) t
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), rs -> {
            if (!rs.next()) {
                return EnterpriseProposalSummaryDTO.builder()
                        .total(0).pending(0).approved(0).totalBudget(0)
                        .build();
            }
            return EnterpriseProposalSummaryDTO.builder()
                    .total(rs.getLong("total"))
                    .pending(rs.getLong("pending"))
                    .approved(rs.getLong("approved"))
                    .totalBudget(rs.getDouble("total_budget"))
                    .build();
        });
    }

    public List<EnterpriseProposalDTO> getProposals(User user, String status) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT id, title, budget, created_at,
                         CASE
                           WHEN status = 'REJECTED' THEN 'REJECTED'
                           WHEN validated = 'approved' OR status IN ('VALIDATED', 'RECRUITING', 'IN_PROGRESS', 'COMPLETED') THEN 'APPROVED'
                           ELSE 'PENDING'
                         END AS proposal_status
                FROM projects
                WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                """;
        StringBuilder sb = new StringBuilder(sql);
        Map<String, Object> params = new java.util.HashMap<>();
        params.put("enterpriseId", enterpriseId);
        if (status != null && !status.equalsIgnoreCase("ALL")) {
            sb.append(" AND (");
            sb.append("CASE WHEN status = 'REJECTED' THEN 'REJECTED' ");
            sb.append("WHEN validated = 'approved' OR status IN ('VALIDATED', 'RECRUITING', 'IN_PROGRESS', 'COMPLETED') THEN 'APPROVED' ");
            sb.append("ELSE 'PENDING' END) = :status");
            params.put("status", status);
        }
        sb.append(" ORDER BY created_at DESC");

        return jdbcTemplate.query(sb.toString(), params, (rs, rowNum) -> EnterpriseProposalDTO.builder()
                .key(String.valueOf(rs.getLong("id")))
                .name(rs.getString("title"))
                .budget(rs.getDouble("budget"))
                .status(rs.getString("proposal_status"))
                .createdAt(toLocalDateTime(rs.getTimestamp("created_at")))
                .build());
    }

    public EnterprisePaymentSummaryDTO getPaymentSummary(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT
                  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS paid,
                  SUM(CASE WHEN status != 'COMPLETED' AND (payment_link_expires_at IS NULL OR payment_link_expires_at >= NOW()) THEN 1 ELSE 0 END) AS pending,
                  SUM(CASE WHEN status != 'COMPLETED' AND payment_link_expires_at < NOW() THEN 1 ELSE 0 END) AS overdue,
                  COALESCE(SUM(CASE WHEN status != 'COMPLETED' THEN amount ELSE 0 END), 0) AS remaining
                FROM payments
                WHERE enterprise_id = :enterpriseId
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), rs -> {
            if (!rs.next()) {
                return EnterprisePaymentSummaryDTO.builder()
                        .paid(0).pending(0).overdue(0).remaining(0)
                        .build();
            }
            return EnterprisePaymentSummaryDTO.builder()
                    .paid(rs.getLong("paid"))
                    .pending(rs.getLong("pending"))
                    .overdue(rs.getLong("overdue"))
                    .remaining(rs.getDouble("remaining"))
                    .build();
        });
    }

    public List<EnterprisePaymentDTO> getPayments(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT p.id, p.payment_code, p.amount, p.payment_link_expires_at, p.status, pr.title
                FROM payments p
                JOIN projects pr ON pr.id = p.project_id
                WHERE p.enterprise_id = :enterpriseId
                ORDER BY p.created_at DESC
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), new PaymentRowMapper());
    }

    public EnterprisePaymentDTO createPayment(User user, CreateEnterprisePaymentRequest request) {
        long enterpriseId = requireEnterpriseId(user);
        validateProjectOwnership(request.getProjectId(), enterpriseId);

        String code = "PMT-" + System.currentTimeMillis();
        LocalDate due = request.getDueDate();
        LocalDateTime dueDateTime = due != null ? due.atStartOfDay() : null;

        String sql = """
                INSERT INTO payments (project_id, enterprise_id, payment_code, amount, currency, status,
                                      payment_method, payment_link_expires_at, description, created_at)
                VALUES (:projectId, :enterpriseId, :paymentCode, :amount, 'VND', 'PENDING',
                        :paymentMethod, :dueDate, :description, NOW())
                """;

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("projectId", request.getProjectId())
                .addValue("enterpriseId", enterpriseId)
                .addValue("paymentCode", code)
                .addValue("amount", request.getAmount())
                .addValue("paymentMethod", request.getPaymentMethod())
                .addValue("dueDate", dueDateTime)
                .addValue("description", request.getDescription());

        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(sql, params, keyHolder, new String[]{"id"});
        Number id = keyHolder.getKey();
        if (id == null) {
            throw new IllegalStateException("Không thể tạo yêu cầu thanh toán");
        }

        return getPaymentById(id.longValue(), enterpriseId);
    }

    public EnterpriseReportSummaryDTO getReportSummary(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT
                  COUNT(*) AS total_projects,
                  COALESCE(SUM(budget), 0) AS total_cost,
                  COALESCE(AVG(progress_percentage), 0) AS avg_progress,
                  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_projects
                FROM projects
                WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), rs -> {
            if (!rs.next()) {
                return EnterpriseReportSummaryDTO.builder()
                        .projects(0).totalCost(0).performance(0).completedRate(0)
                        .build();
            }
            long totalProjects = rs.getLong("total_projects");
            long completed = rs.getLong("completed_projects");
            double completedRate = totalProjects == 0 ? 0 : (completed * 100.0) / totalProjects;
            return EnterpriseReportSummaryDTO.builder()
                    .projects(totalProjects)
                    .totalCost(rs.getDouble("total_cost"))
                    .performance(rs.getDouble("avg_progress"))
                    .completedRate(completedRate)
                    .build();
        });
    }

    private EnterprisePaymentDTO getPaymentById(long paymentId, long enterpriseId) {
        String sql = """
                SELECT p.id, p.payment_code, p.amount, p.payment_link_expires_at, p.status, pr.title
                FROM payments p
                JOIN projects pr ON pr.id = p.project_id
                WHERE p.id = :paymentId AND p.enterprise_id = :enterpriseId
                """;
        List<EnterprisePaymentDTO> rows = jdbcTemplate.query(sql, Map.of("paymentId", paymentId, "enterpriseId", enterpriseId), new PaymentRowMapper());
        if (rows.isEmpty()) {
            throw new ResourceNotFoundException("Payment not found");
        }
        return rows.get(0);
    }

    public List<EnterpriseProjectReportDTO> getProjectReports(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT id, title, budget, progress_percentage, status
                FROM projects
                WHERE enterprise_id = :enterpriseId AND deleted_at IS NULL
                ORDER BY created_at DESC
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), (rs, rowNum) -> EnterpriseProjectReportDTO.builder()
                .key(String.valueOf(rs.getLong("id")))
                .name(rs.getString("title"))
                .cost(rs.getDouble("budget"))
                .progress(rs.getInt("progress_percentage"))
                .status(rs.getString("status"))
                .build());
    }

    public List<EnterpriseFeedbackDTO> getFeedbacks(User user) {
        long enterpriseId = requireEnterpriseId(user);
        String sql = """
                SELECT f.id, f.project_id, p.title,
                       f.overall_rating, f.quality_rating, f.communication_rating, f.timeline_rating, f.professionalism_rating,
                       f.positive_feedback, f.negative_feedback, f.suggestions,
                       f.would_recommend, f.would_work_again,
                       f.status, f.submitted_at, f.created_at
                FROM enterprise_feedback f
                JOIN projects p ON p.id = f.project_id
                WHERE f.enterprise_id = :enterpriseId
                ORDER BY f.created_at DESC
                """;
        return jdbcTemplate.query(sql, Map.of("enterpriseId", enterpriseId), (rs, rowNum) -> EnterpriseFeedbackDTO.builder()
                .id(rs.getLong("id"))
                .projectId(rs.getLong("project_id"))
                .projectName(rs.getString("title"))
                .overallRating(rs.getObject("overall_rating") != null ? rs.getDouble("overall_rating") : null)
                .qualityRating(rs.getObject("quality_rating") != null ? rs.getDouble("quality_rating") : null)
                .communicationRating(rs.getObject("communication_rating") != null ? rs.getDouble("communication_rating") : null)
                .timelineRating(rs.getObject("timeline_rating") != null ? rs.getDouble("timeline_rating") : null)
                .professionalismRating(rs.getObject("professionalism_rating") != null ? rs.getDouble("professionalism_rating") : null)
                .positiveFeedback(rs.getString("positive_feedback"))
                .negativeFeedback(rs.getString("negative_feedback"))
                .suggestions(rs.getString("suggestions"))
                .wouldRecommend(rs.getObject("would_recommend") != null ? rs.getBoolean("would_recommend") : null)
                .wouldWorkAgain(rs.getObject("would_work_again") != null ? rs.getBoolean("would_work_again") : null)
                .status(rs.getString("status"))
                .submittedAt(rs.getTimestamp("submitted_at") != null ? rs.getTimestamp("submitted_at").toString() : null)
                .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : null)
                .build());
    }

    public EnterpriseFeedbackDTO createFeedback(User user, CreateEnterpriseFeedbackRequest request) {
        long enterpriseId = requireEnterpriseId(user);
        validateProjectOwnership(request.getProjectId(), enterpriseId);
        ensureProjectCompleted(request.getProjectId(), enterpriseId);
        if (request.getOverallRating() == null || request.getOverallRating() < 1 || request.getOverallRating() > 5) {
            throw new IllegalArgumentException("Điểm đánh giá phải từ 1 đến 5");
        }
        if (request.getPositiveFeedback() == null || request.getPositiveFeedback().trim().isEmpty()) {
            throw new IllegalArgumentException("Thiếu nội dung phản hồi");
        }

        String insertSql = """
                INSERT INTO enterprise_feedback (
                    enterprise_id, project_id,
                    overall_rating, quality_rating, communication_rating, timeline_rating, professionalism_rating,
                    positive_feedback, negative_feedback, suggestions,
                    would_recommend, would_work_again,
                    status, submitted_at, created_at
                )
                VALUES (
                    :enterpriseId, :projectId,
                    :overallRating, :qualityRating, :communicationRating, :timelineRating, :professionalismRating,
                    :positiveFeedback, :negativeFeedback, :suggestions,
                    :wouldRecommend, :wouldWorkAgain,
                    :status, NOW(), NOW()
                )
                """;
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("enterpriseId", enterpriseId)
                .addValue("projectId", request.getProjectId())
                .addValue("overallRating", request.getOverallRating())
                .addValue("qualityRating", request.getQualityRating())
                .addValue("communicationRating", request.getCommunicationRating())
                .addValue("timelineRating", request.getTimelineRating())
                .addValue("professionalismRating", request.getProfessionalismRating())
                .addValue("positiveFeedback", request.getPositiveFeedback().trim())
                .addValue("negativeFeedback", request.getNegativeFeedback())
                .addValue("suggestions", request.getSuggestions())
                .addValue("wouldRecommend", request.getWouldRecommend())
                .addValue("wouldWorkAgain", request.getWouldWorkAgain())
                .addValue("status", "SUBMITTED");
        jdbcTemplate.update(insertSql, params);

        String fetchSql = """
                SELECT f.id, f.project_id, p.title,
                       f.overall_rating, f.quality_rating, f.communication_rating, f.timeline_rating, f.professionalism_rating,
                       f.positive_feedback, f.negative_feedback, f.suggestions,
                       f.would_recommend, f.would_work_again,
                       f.status, f.submitted_at, f.created_at
                FROM enterprise_feedback f
                JOIN projects p ON p.id = f.project_id
                WHERE f.enterprise_id = :enterpriseId
                ORDER BY f.id DESC
                LIMIT 1
                """;
        List<EnterpriseFeedbackDTO> rows = jdbcTemplate.query(fetchSql, Map.of("enterpriseId", enterpriseId),
                (rs, rowNum) -> EnterpriseFeedbackDTO.builder()
                        .id(rs.getLong("id"))
                        .projectId(rs.getLong("project_id"))
                        .projectName(rs.getString("title"))
                        .overallRating(rs.getObject("overall_rating") != null ? rs.getDouble("overall_rating") : null)
                        .qualityRating(rs.getObject("quality_rating") != null ? rs.getDouble("quality_rating") : null)
                        .communicationRating(rs.getObject("communication_rating") != null ? rs.getDouble("communication_rating") : null)
                        .timelineRating(rs.getObject("timeline_rating") != null ? rs.getDouble("timeline_rating") : null)
                        .professionalismRating(rs.getObject("professionalism_rating") != null ? rs.getDouble("professionalism_rating") : null)
                        .positiveFeedback(rs.getString("positive_feedback"))
                        .negativeFeedback(rs.getString("negative_feedback"))
                        .suggestions(rs.getString("suggestions"))
                        .wouldRecommend(rs.getObject("would_recommend") != null ? rs.getBoolean("would_recommend") : null)
                        .wouldWorkAgain(rs.getObject("would_work_again") != null ? rs.getBoolean("would_work_again") : null)
                        .status(rs.getString("status"))
                        .submittedAt(rs.getTimestamp("submitted_at") != null ? rs.getTimestamp("submitted_at").toString() : null)
                        .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString() : null)
                        .build());
        return rows.isEmpty() ? null : rows.get(0);
    }

    private void ensureProjectCompleted(Long projectId, long enterpriseId) {
        Integer progress = jdbcTemplate.query("""
                        SELECT progress_percentage
                        FROM projects
                        WHERE id = :projectId AND enterprise_id = :enterpriseId AND deleted_at IS NULL
                        """,
                Map.of("projectId", projectId, "enterpriseId", enterpriseId),
                rs -> rs.next() ? rs.getInt("progress_percentage") : null);
        if (progress == null) {
            throw new ResourceNotFoundException("Project not found for enterprise");
        }
        if (progress < 100) {
            throw new IllegalStateException("Chỉ dự án hoàn thành 100% mới được đánh giá");
        }
    }

    private long requireEnterpriseId(User user) {
        Optional<Long> enterpriseId = jdbcTemplate.query(
                "SELECT id FROM enterprises WHERE user_id = :userId AND deleted_at IS NULL",
                Map.of("userId", user.getId()),
                (rs, rowNum) -> rs.getLong("id")
        ).stream().findFirst();
        return enterpriseId.orElseThrow(() -> new ResourceNotFoundException("Enterprise not found for user"));
    }

    private void validateProjectOwnership(Long projectId, long enterpriseId) {
        if (projectId == null) {
            throw new IllegalArgumentException("Thiếu projectId");
        }
        Integer count = jdbcTemplate.query("""
                        SELECT COUNT(*) AS cnt
                        FROM projects
                        WHERE id = :projectId AND enterprise_id = :enterpriseId AND deleted_at IS NULL
                        """,
                Map.of("projectId", projectId, "enterpriseId", enterpriseId),
                rs -> rs.next() ? rs.getInt("cnt") : 0);
        if (count == null || count == 0) {
            throw new ResourceNotFoundException("Project not found for enterprise");
        }
    }

    private ProjectMeta requireEnterpriseProject(long projectId, long enterpriseId) {
        String sql = """
                SELECT id, status
                FROM projects
                WHERE id = :projectId AND enterprise_id = :enterpriseId AND deleted_at IS NULL
                """;
        List<ProjectMeta> rows = jdbcTemplate.query(sql, Map.of("projectId", projectId, "enterpriseId", enterpriseId),
                (rs, rowNum) -> new ProjectMeta(rs.getLong("id"), rs.getString("status")));
        if (rows.isEmpty()) {
            throw new ResourceNotFoundException("Project not found for enterprise");
        }
        return rows.get(0);
    }

    private void insertTechnologies(long projectId, List<String> technologies) {
        if (technologies == null || technologies.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO project_technologies (project_id, technology_name) VALUES (:projectId, :name)";
        technologies.stream()
                .filter(t -> t != null && !t.trim().isEmpty())
                .map(String::trim)
                .distinct()
                .forEach(tech -> jdbcTemplate.update(sql, Map.of("projectId", projectId, "name", tech)));
    }

    private void insertSkills(long projectId, List<String> skills) {
        if (skills == null || skills.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO project_skill_requirements (project_id, skill_name, proficiency_level, priority) VALUES (:projectId, :name, :level, :priority)";
        List<String> sorted = skills.stream()
                .filter(s -> s != null && !s.trim().isEmpty())
                .map(String::trim)
                .distinct()
                .sorted()
                .toList();
        for (int i = 0; i < sorted.size(); i++) {
            jdbcTemplate.update(sql, Map.of(
                    "projectId", projectId,
                    "name", sorted.get(i),
                    "level", "INTERMEDIATE",
                    "priority", i + 1
            ));
        }
    }

    private static LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }

    private EnterpriseMentorOptionDTO toMentorOption(Mentor mentor) {
        return EnterpriseMentorOptionDTO.builder()
                .id(mentor.getId())
                .fullName(mentor.getFullName())
                .title(mentor.getTitle())
                .currentCompany(mentor.getCurrentCompany())
                .ratingAverage(mentor.getRatingAverage())
                .available(mentor.getAvailable())
                .build();
    }

    private static class PaymentRowMapper implements RowMapper<EnterprisePaymentDTO> {
        @Override
        public EnterprisePaymentDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            String status = rs.getString("status");
            LocalDateTime dueDate = toLocalDateTime(rs.getTimestamp("payment_link_expires_at"));
            String mappedStatus;
            if ("COMPLETED".equalsIgnoreCase(status)) {
                mappedStatus = "PAID";
            } else if (dueDate != null && dueDate.isBefore(LocalDateTime.now())) {
                mappedStatus = "OVERDUE";
            } else {
                mappedStatus = "PENDING";
            }
            return EnterprisePaymentDTO.builder()
                    .key(String.valueOf(rs.getLong("id")))
                    .code(rs.getString("payment_code"))
                    .project(rs.getString("title"))
                    .amount(rs.getDouble("amount"))
                    .dueDate(dueDate)
                    .status(mappedStatus)
                    .build();
        }
    }

    private record ProjectMeta(long id, String status) {
    }

    private record ProjectStartMeta(String status, int members) {
    }
}
