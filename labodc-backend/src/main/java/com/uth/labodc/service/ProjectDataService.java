package com.uth.labodc.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.uth.labodc.dto.project.ProjectMemberResponse;
import com.uth.labodc.dto.project.ProjectResponse;
import com.uth.labodc.exception.BadRequestException;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.model.enums.UserRole;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.sql.ResultSet;
import java.util.Comparator;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectDataService {

    private static final String BASE_SELECT = """
            SELECT p.id,
                   p.title,
                   p.description,
                   p.objectives,
                   p.requirements,
                   p.start_date,
                   p.end_date,
                   p.budget,
                   p.number_of_students,
                   p.status,
                   p.enterprise_id,
                   p.mentor_id,
                   m.full_name AS mentor_name,
                   p.created_at,
                   p.updated_at,
                   p.validated,
                   pr.rejection_reason,
                   p.progress_percentage
            FROM projects p
            LEFT JOIN project_rejections pr ON p.id = pr.project_id
            LEFT JOIN mentors m ON p.mentor_id = m.id
            WHERE p.deleted_at IS NULL
            """;

    private static final Map<String, List<String>> STATUS_FILTERS = Map.of(
            "draft", List.of("DRAFT"),
            "pending", List.of("PENDING_VALIDATION"),
            "approved", List.of("VALIDATED", "RECRUITING"),
            "rejected", List.of("REJECTED"),
            "inProgress", List.of("IN_PROGRESS"),
            "completed", List.of("COMPLETED"),
            "cancelled", List.of("CANCELLED", "ARCHIVED")
    );

    private static final Set<String> JOINABLE_STATUSES = Set.of("RECRUITING", "IN_PROGRESS", "VALIDATED");

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public ProjectResponse createProject(User user, com.uth.labodc.dto.project.CreateProjectRequest request) {
        if (user.getRole() != UserRole.ENTERPRISE && user.getRole() != UserRole.LAB_ADMIN) {
            throw new BadRequestException("Chỉ doanh nghiệp hoặc quản trị có thể tạo dự án");
        }

        Long enterpriseId;
        if (user.getRole() == UserRole.ENTERPRISE) {
            enterpriseId = findEnterpriseId(user.getId())
                    .orElseThrow(() -> new BadRequestException("Không tìm thấy hồ sơ Doanh nghiệp"));
        } else {
            enterpriseId = Optional.ofNullable(request.getEnterpriseId())
                    .orElseThrow(() -> new BadRequestException("Thiếu enterpriseId cho dự án"));
        }

        if (request.getStartDate() != null && request.getEndDate() != null
                && request.getStartDate().isAfter(request.getEndDate())) {
            throw new BadRequestException("Ngày bắt đầu phải trước ngày kết thúc");
        }

        String objectivesJson = null;
        try {
            if (request.getObjectives() != null && !request.getObjectives().isEmpty()) {
                objectivesJson = objectMapper.writeValueAsString(request.getObjectives());
            }
        } catch (IOException e) {
            throw new BadRequestException("Không thể lưu mục tiêu dự án");
        }

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("title", request.getName())
                .addValue("slug", generateSlug(request.getName()))
                .addValue("description", request.getDescription())
                .addValue("objectives", objectivesJson)
                .addValue("requirements", request.getRequirements())
                .addValue("startDate", request.getStartDate())
                .addValue("endDate", request.getEndDate())
                .addValue("budget", request.getBudget())
                .addValue("numberOfStudents", request.getRequiredTalents())
                .addValue("status", "PENDING_VALIDATION")
                .addValue("enterpriseId", enterpriseId)
                .addValue("mentorId", request.getMentorId())
                .addValue("allowApplications", Optional.ofNullable(request.getAllowApplications()).orElse(Boolean.TRUE));

        String sql = """
                INSERT INTO projects (title, slug, description, objectives, requirements, start_date, end_date, budget,
                                     number_of_students, status, enterprise_id, mentor_id, allow_applications,
                                     current_members_count, created_at, updated_at)
                VALUES (:title, :slug, :description, :objectives, :requirements, :startDate, :endDate, :budget,
                        :numberOfStudents, :status, :enterpriseId, :mentorId, :allowApplications,
                        0, NOW(), NOW())
                """;

        KeyHolder keyHolder = new GeneratedKeyHolder();
        int inserted = jdbcTemplate.update(sql, params, keyHolder, new String[]{"id"});
        if (inserted == 0 || keyHolder.getKey() == null) {
            throw new BadRequestException("Không thể tạo dự án");
        }

        long projectId = keyHolder.getKey().longValue();
        insertTechnologies(projectId, request.getTechnologies());
        insertSkills(projectId, request.getRequiredSkills());

        return getProjectById(projectId);
    }

    public List<ProjectResponse> getProjects(String clientStatus) {
        Map<String, Object> params = new HashMap<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        if (clientStatus != null) {
            List<String> dbStatuses = STATUS_FILTERS.getOrDefault(clientStatus, Collections.emptyList());
            if (!dbStatuses.isEmpty()) {
                sql.append(" AND p.status IN (:statuses)");
                params.put("statuses", dbStatuses);
            }
        }
        sql.append(" ORDER BY p.created_at DESC");
        return mapProjects(sql.toString(), params);
    }

    public List<ProjectResponse> getProjectsByEnterprise(long enterpriseId) {
        String sql = BASE_SELECT + " AND p.enterprise_id = :enterpriseId ORDER BY p.created_at DESC";
        return mapProjects(sql, Map.of("enterpriseId", enterpriseId));
    }

    public List<ProjectResponse> getProjectsForUser(User user) {
        if (user.getRole() == UserRole.ENTERPRISE) {
            return findEnterpriseId(user.getId())
                    .map(this::getProjectsByEnterprise)
                    .orElseGet(Collections::emptyList);
        }
        if (user.getRole() == UserRole.TALENT) {
            return findTalentId(user.getId())
                    .map(this::getProjectsForTalent)
                    .orElseGet(Collections::emptyList);
        }
        if (user.getRole() == UserRole.MENTOR) {
            return findMentorId(user.getId())
                    .map(this::getProjectsByMentor)
                    .orElseGet(Collections::emptyList);
        }
        return getProjects(null);
    }

    public List<ProjectMemberResponse> getProjectMembers(long projectId) {
        final String sql = """
                SELECT id, project_id, talent_id, role, joined_at
                FROM project_members
                WHERE project_id = :projectId
                ORDER BY joined_at NULLS LAST, id
                """;
        return jdbcTemplate.query(sql, Map.of("projectId", projectId), (rs, rowNum) -> ProjectMemberResponse.builder()
                .id(rs.getLong("id"))
                .projectId(rs.getLong("project_id"))
                .talentId(rs.getLong("talent_id"))
                .role(rs.getString("role"))
                .joinedAt(toLocalDateTime(rs.getTimestamp("joined_at")))
                .build());
    }

    @Transactional
    public void joinProject(long projectId, User user, String motivationLetter) {
        if (user.getRole() != UserRole.TALENT) {
            throw new BadRequestException("Chỉ tài khoản Talent mới có thể tham gia dự án");
        }
        Long talentId = findTalentId(user.getId())
                .orElseThrow(() -> new BadRequestException("Không tìm thấy hồ sơ Talent cho tài khoản này"));

        ProjectMeta meta = fetchProjectMeta(projectId);
        if (!Boolean.TRUE.equals(meta.allowApplications()) || !JOINABLE_STATUSES.contains(meta.status())) {
            throw new BadRequestException("Dự án hiện không nhận thêm thành viên");
        }

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("projectId", projectId)
                .addValue("talentId", talentId)
                .addValue("motivation", motivationLetter);

        int inserted = jdbcTemplate.update("""
                        INSERT INTO project_members (project_id, talent_id, role, status, joined_at)
                        VALUES (:projectId, :talentId, 'MEMBER', 'ACTIVE', NOW())
                        ON CONFLICT (project_id, talent_id) DO NOTHING
                        """,
                params);

        if (inserted == 0) {
            throw new BadRequestException("Bạn đã tham gia dự án này");
        }

        jdbcTemplate.update("UPDATE projects SET current_members_count = current_members_count + 1 WHERE id = :projectId",
                params);
    }

    @Transactional
    public void leaveProject(long projectId, User user) {
        if (user.getRole() != UserRole.TALENT) {
            throw new BadRequestException("Chỉ tài khoản Talent mới có thể rời dự án");
        }
        Long talentId = findTalentId(user.getId())
                .orElseThrow(() -> new BadRequestException("Không tìm thấy hồ sơ Talent cho tài khoản này"));

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("projectId", projectId)
                .addValue("talentId", talentId);

        int removed = jdbcTemplate.update("DELETE FROM project_members WHERE project_id = :projectId AND talent_id = :talentId",
                params);

        if (removed == 0) {
            throw new BadRequestException("Bạn chưa tham gia dự án này");
        }

        jdbcTemplate.update("""
                        UPDATE projects
                        SET current_members_count = GREATEST(current_members_count - 1, 0)
                        WHERE id = :projectId
                        """,
                params);
    }

    private List<ProjectResponse> getProjectsForTalent(long talentId) {
        final String sql = BASE_SELECT + " AND p.id IN (SELECT project_id FROM project_members WHERE talent_id = :talentId) ORDER BY p.created_at DESC";
        return mapProjects(sql, Map.of("talentId", talentId));
    }

    private List<ProjectResponse> getProjectsByMentor(long mentorId) {
        final String sql = BASE_SELECT + " AND p.mentor_id = :mentorId ORDER BY p.created_at DESC";
        return mapProjects(sql, Map.of("mentorId", mentorId));
    }

    private ProjectMeta fetchProjectMeta(long projectId) {
        final String sql = "SELECT id, status, allow_applications FROM projects WHERE id = :projectId";
        return jdbcTemplate.query(sql, Map.of("projectId", projectId), rs -> {
            if (rs.next()) {
                return new ProjectMeta(rs.getLong("id"), rs.getString("status"), rs.getBoolean("allow_applications"));
            }
            throw new ResourceNotFoundException("Project not found");
        });
    }

    private Optional<Long> findEnterpriseId(long userId) {
        final String sql = "SELECT id FROM enterprises WHERE user_id = :userId LIMIT 1";
        return querySingleId(sql, userId);
    }

    private Optional<Long> findTalentId(long userId) {
        final String sql = "SELECT id FROM talents WHERE user_id = :userId LIMIT 1";
        return querySingleId(sql, userId);
    }

    private Optional<Long> findMentorId(long userId) {
        final String sql = "SELECT id FROM mentors WHERE user_id = :userId LIMIT 1";
        return querySingleId(sql, userId);
    }

    private Optional<Long> querySingleId(String sql, long userId) {
        List<Long> ids = jdbcTemplate.query(sql, Map.of("userId", userId), (rs, rowNum) -> rs.getLong("id"));
        return ids.stream().findFirst();
    }

    private List<ProjectResponse> mapProjects(String sql, Map<String, ?> params) {
        List<ProjectRow> rows = jdbcTemplate.query(sql, params, new ProjectRowMapper());
        if (rows.isEmpty()) {
            return List.of();
        }
        List<Long> ids = rows.stream().map(ProjectRow::id).toList();
        Map<Long, List<String>> technologies = loadValues(ids,
                "SELECT project_id, technology_name FROM project_technologies WHERE project_id IN (:ids) ORDER BY technology_name",
                "technology_name");
        Map<Long, List<String>> skills = loadValues(ids,
                "SELECT project_id, skill_name FROM project_skill_requirements WHERE project_id IN (:ids) ORDER BY priority, skill_name",
                "skill_name");

        return rows.stream()
                .map(row -> toResponse(row, technologies.get(row.id()), skills.get(row.id())))
                .collect(Collectors.toList());
    }

    public ProjectResponse getProjectById(long projectId) {
        String sql = BASE_SELECT + " AND p.id = :projectId";
        List<ProjectResponse> results = mapProjects(sql, Map.of("projectId", projectId));
        return results.stream().findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Project not found with id: " + projectId));
    }

    private void insertTechnologies(long projectId, List<String> technologies) {
        if (technologies == null || technologies.isEmpty()) {
            return;
        }
        final String sql = "INSERT INTO project_technologies (project_id, technology_name) VALUES (:projectId, :name)";
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
        final String sql = "INSERT INTO project_skill_requirements (project_id, skill_name, proficiency_level, priority) VALUES (:projectId, :name, :level, :priority)";
        List<String> sorted = skills.stream()
                .filter(s -> s != null && !s.trim().isEmpty())
                .map(String::trim)
                .distinct()
                .sorted(Comparator.naturalOrder())
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

    private Map<Long, List<String>> loadValues(Collection<Long> projectIds, String sql, String column) {
        if (projectIds == null || projectIds.isEmpty()) {
            return Map.of();
        }
        Map<Long, List<String>> result = new LinkedHashMap<>();
        jdbcTemplate.query(sql, Map.of("ids", projectIds), (rs, rowNum) -> {
            long projectId = rs.getLong("project_id");
            String value = rs.getString(column);
            result.computeIfAbsent(projectId, k -> new ArrayList<>()).add(value);
            return null;
        });
        return result;
    }

    private ProjectResponse toResponse(ProjectRow row, List<String> techs, List<String> skills) {
        return ProjectResponse.builder()
                .id(row.id())
                .name(row.title())
                .description(row.description())
                .objective(buildObjective(row))
                .technologies(techs != null ? techs : new ArrayList<>())
                .startDate(toDateTime(row.startDate()))
                .endDate(toDateTime(row.endDate()))
                .budget(row.budget())
                .requiredTalents(row.numberOfStudents())
                .requiredSkills(skills != null ? skills : new ArrayList<>())
                .status(mapDbStatus(row.status()))
                .enterpriseId(row.enterpriseId())
                .mentorId(row.mentorId())
                .mentorName(row.mentorName())
                .createdAt(row.createdAt())
                .updatedAt(row.updatedAt())
                .validated(row.validated() != null ? row.validated() : "pending")
                .rejectionReason(row.rejectionReason())
                .progressPercentage(row.progressPercentage())
                .build();
    }

    private String buildObjective(ProjectRow row) {
        if (row.objectives() != null) {
            try {
                List<String> objectives = objectMapper.readValue(row.objectives(), new TypeReference<List<String>>() {
                });
                if (!objectives.isEmpty()) {
                    return String.join("\n", objectives);
                }
            } catch (IOException e) {
                log.warn("Unable to parse objectives for project {}", row.id(), e);
            }
        }
        if (row.requirements() != null) {
            return row.requirements();
        }
        return row.description();
    }

    private String mapDbStatus(String dbStatus) {
        return switch (dbStatus) {
            case "DRAFT" -> "draft";
            case "PENDING_VALIDATION", "ON_HOLD" -> "pending";
            case "VALIDATED", "RECRUITING" -> "approved";
            case "REJECTED" -> "rejected";
            case "IN_PROGRESS" -> "inProgress";
            case "COMPLETED" -> "completed";
            case "CANCELLED", "ARCHIVED" -> "cancelled";
            default -> "pending";
        };
    }

    private String generateSlug(String name) {
        if (name == null) {
            return "project-" + System.currentTimeMillis();
        }
        String base = name.trim().toLowerCase()
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-{2,}", "-");
        if (base.isBlank()) {
            base = "project";
        }
        return base + "-" + System.currentTimeMillis();
    }

    private LocalDateTime toDateTime(LocalDate date) {
        return date != null ? date.atStartOfDay() : null;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp != null ? timestamp.toLocalDateTime() : null;
    }

    private static class ProjectRowMapper implements RowMapper<ProjectRow> {
        @Override
        public ProjectRow mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new ProjectRow(
                    rs.getLong("id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("objectives"),
                    rs.getString("requirements"),
                    rs.getDate("start_date").toLocalDate(),
                    rs.getDate("end_date").toLocalDate(),
                    rs.getBigDecimal("budget").doubleValue(),
                    rs.getInt("number_of_students"),
                    rs.getString("status"),
                    rs.getLong("enterprise_id"),
                    rs.getObject("mentor_id") != null ? rs.getLong("mentor_id") : null,
                    rs.getString("mentor_name"),
                    toLocalDateTime(rs.getTimestamp("created_at")),
                    toLocalDateTime(rs.getTimestamp("updated_at")),
                    rs.getString("validated"),
                    rs.getString("rejection_reason"),
                    rs.getObject("progress_percentage") != null ? rs.getInt("progress_percentage") : 0
            );
        }

        private LocalDateTime toLocalDateTime(Timestamp timestamp) {
            return timestamp != null ? timestamp.toLocalDateTime() : null;
        }
    }

    private record ProjectRow(
            Long id,
            String title,
            String description,
            String objectives,
            String requirements,
            LocalDate startDate,
            LocalDate endDate,
            Double budget,
            Integer numberOfStudents,
            String status,
            Long enterpriseId,
            Long mentorId,
            String mentorName,
            LocalDateTime createdAt,
            LocalDateTime updatedAt,
            String validated,
            String rejectionReason,
            Integer progressPercentage
    ) {
    }

    private record ProjectMeta(long id, String status, Boolean allowApplications) {
    }
}
