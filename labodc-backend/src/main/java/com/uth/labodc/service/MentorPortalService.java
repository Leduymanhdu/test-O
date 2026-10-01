package com.uth.labodc.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.uth.labodc.dto.mentor.*;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.Mentor;
import com.uth.labodc.model.entity.MentorInvitation;
import com.uth.labodc.model.entity.MentorReport;
import com.uth.labodc.model.entity.MentorTask;
import com.uth.labodc.model.entity.MentorTaskSubmission;
import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.entity.ProjectMember;
import com.uth.labodc.model.entity.Talent;
import com.uth.labodc.model.entity.TalentEvaluation;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.MentorInvitationRepository;
import com.uth.labodc.repository.MentorReportRepository;
import com.uth.labodc.repository.MentorRepository;
import com.uth.labodc.repository.MentorTaskRepository;
import com.uth.labodc.repository.MentorTaskSubmissionRepository;
import com.uth.labodc.repository.ProjectRepository;
import com.uth.labodc.repository.TalentEvaluationRepository;
import com.uth.labodc.repository.TalentRepository;
import com.uth.labodc.repository.ProjectMemberRepository;
import com.uth.labodc.repository.TalentSkillRepository;
import com.uth.labodc.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class MentorPortalService {

    private final MentorRepository mentorRepository;
    private final MentorInvitationRepository mentorInvitationRepository;
    private final MentorTaskRepository mentorTaskRepository;
    private final MentorReportRepository mentorReportRepository;
    private final MentorTaskSubmissionRepository mentorTaskSubmissionRepository;
    private final ProjectRepository projectRepository;
    private final TalentRepository talentRepository;
    private final TalentEvaluationRepository talentEvaluationRepository;
    private final ProjectDataService projectDataService;
    private final ObjectMapper objectMapper;
    private final ProjectMemberRepository projectMemberRepository;
    private final TalentSkillRepository talentSkillRepository;
    private final UserRepository userRepository;

    public List<MentorProjectOptionDTO> getProjects(User user) {
        Mentor mentor = requireMentor(user);
        List<Project> projects = projectRepository.findByMentorId(mentor.getId());
        return projects.stream()
                .map(p -> MentorProjectOptionDTO.builder()
                        .id(p.getId())
                        .title(p.getTitle())
                        .progressPercentage(p.getProgressPercentage())
                        .build())
                .toList();
    }

    public MentorDashboardDTO getDashboard(User user) {
        Mentor mentor = requireMentor(user);

        long projectCount = projectRepository.countByMentorId(mentor.getId());
        long pendingInvitations = mentorInvitationRepository.findPendingByMentorIdOrderByReceivedDateDesc(mentor.getId()).size();
        long reportCount = mentorReportRepository.findByMentorIdOrderByDueDateDesc(mentor.getId()).size();

        int studentCount = sumStudentsForMentorProjects(mentor.getId());

        List<MentorStatCardDTO> stats = List.of(
                MentorStatCardDTO.builder().id("students").title("Sinh viên đang hướng dẫn").value(studentCount).color("#1890ff").build(),
                MentorStatCardDTO.builder().id("projects").title("Dự án đang theo dõi").value(projectCount).color("#52c41a").build(),
                MentorStatCardDTO.builder().id("reports").title("Báo cáo cần xử lý").value(reportCount).color("#722ed1").build(),
                MentorStatCardDTO.builder().id("pending").title("Lời mời chờ phản hồi").value(pendingInvitations).color("#faad14").build()
        );

        List<MentorQuickActionDTO> quickActions = List.of(
                MentorQuickActionDTO.builder().id("invitations").title("Xem lời mời").description("Duyệt lời mời tham gia dự án").variant("primary").build(),
                MentorQuickActionDTO.builder().id("tasks").title("Quản lý task").description("Theo dõi tiến độ và giao việc").variant("ghost").build(),
                MentorQuickActionDTO.builder().id("evaluation").title("Đánh giá").description("Đánh giá năng lực sinh viên").variant("ghost").build(),
                MentorQuickActionDTO.builder().id("reports").title("Gửi báo cáo").description("Nộp báo cáo minh bạch/tiến độ").variant("success").build()
        );

        List<MentorActivityDTO> activities = buildRecentActivities(mentor.getId());

        return MentorDashboardDTO.builder()
                .stats(stats)
                .quickActions(quickActions)
                .recentActivities(activities)
                .build();
    }

    public List<MentorInvitationDTO> getInvitations(User user) {
        Mentor mentor = requireMentor(user);
        List<MentorInvitation> invitations = mentorInvitationRepository.findPendingByMentorIdOrderByReceivedDateDesc(mentor.getId());
        if (invitations.isEmpty()) {
            return List.of();
        }

        Map<Long, String> projectTitles = loadProjectTitles(invitations.stream().map(MentorInvitation::getProjectId).distinct().toList());

        List<MentorInvitationDTO> result = new ArrayList<>();
        for (MentorInvitation inv : invitations) {
            result.add(MentorInvitationDTO.builder()
                    .id(String.valueOf(inv.getId()))
                    .projectName(projectTitles.getOrDefault(inv.getProjectId(), "Project #" + inv.getProjectId()))
                    .groupName(inv.getGroupName())
                    .studentCount(inv.getStudentCount() != null ? inv.getStudentCount() : 0)
                    .description(inv.getDescription() != null ? inv.getDescription() : "")
                    .deadline(formatDate(inv.getDeadline() != null ? inv.getDeadline() : (inv.getExpiresAt() != null ? inv.getExpiresAt().toLocalDate() : null)))
                    .skills(parseStringList(inv.getSkills()))
                    .receivedDate(formatDate(inv.getReceivedDate()))
                    .priority(normalizePriority(inv.getPriority()))
                    .build());
        }
        return result;
    }

    public void acceptInvitation(User user, long invitationId) {
        Mentor mentor = requireMentor(user);
        MentorInvitation inv = mentorInvitationRepository.findById(invitationId)
                .orElseThrow(() -> new ResourceNotFoundException("Invitation not found"));
        if (!mentor.getId().equals(inv.getMentorId())) {
            throw new ResourceNotFoundException("Invitation not found");
        }
        Project project = projectRepository.findById(inv.getProjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (project.getMentorId() != null && !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project already has mentor");
        }
        project.setMentorId(mentor.getId());
        projectRepository.save(project);
        inv.setStatus("ACCEPTED");
        inv.setUpdatedAt(LocalDateTime.now());
        mentorInvitationRepository.save(inv);
    }

    public void rejectInvitation(User user, long invitationId, String reason) {
        Mentor mentor = requireMentor(user);
        MentorInvitation inv = mentorInvitationRepository.findById(invitationId)
                .orElseThrow(() -> new ResourceNotFoundException("Invitation not found"));
        if (!mentor.getId().equals(inv.getMentorId())) {
            throw new ResourceNotFoundException("Invitation not found");
        }
        Project project = projectRepository.findById(inv.getProjectId()).orElse(null);
        if (project != null && mentor.getId().equals(project.getMentorId())) {
            project.setMentorId(null);
            project.setUpdatedAt(LocalDateTime.now());
            projectRepository.save(project);
        }
        inv.setStatus("REJECTED");
        inv.setUpdatedAt(LocalDateTime.now());
        mentorInvitationRepository.save(inv);
        if (reason != null && !reason.isBlank()) {
            log.info("Mentor {} rejected invitation {}: {}", mentor.getId(), invitationId, reason);
        }
    }

    public List<MentorTaskDTO> getTasks(User user) {
        Mentor mentor = requireMentor(user);
        List<MentorTask> tasks = mentorTaskRepository.findByMentorIdOrderByDueDateAsc(mentor.getId());
        return tasks.stream().map(this::toTaskDTO).toList();
    }

    public List<MentorTalentOptionDTO> getProjectTalents(User user, long projectId) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        List<Long> talentIds = projectDataService.getProjectMembers(projectId).stream()
            .map(m -> m.getTalentId())
                .filter(id -> id != null && id > 0)
                .distinct()
                .toList();

        if (talentIds.isEmpty()) {
            return List.of();
        }

        Map<Long, Talent> byId = talentRepository.findAllById(talentIds).stream()
                .collect(java.util.stream.Collectors.toMap(Talent::getId, t -> t, (a, b) -> a));

        List<MentorTalentOptionDTO> result = new ArrayList<>();
        for (Long id : talentIds) {
            Talent t = byId.get(id);
            if (t != null) {
                result.add(MentorTalentOptionDTO.builder()
                        .talentId(t.getId())
                        .fullName(t.getFullName())
                        .studentId(t.getStudentId())
                        .build());
            }
        }
        return result;
    }

    public List<MentorTaskDTO> getProjectTasks(User user, long projectId) {
        Mentor mentor = requireMentor(user);
        List<MentorTask> tasks = mentorTaskRepository.findByMentorIdAndProjectIdOrderByDueDateAsc(mentor.getId(), projectId);
        return tasks.stream().map(this::toTaskDTO).toList();
    }

    public List<MentorApplicationDTO> getProjectApplications(User user, long projectId) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        List<ProjectMember> pendingMembers = projectMemberRepository.findByProjectIdAndStatus(
                projectId, ProjectMember.MemberStatus.PENDING);
        if (pendingMembers.isEmpty()) {
            return List.of();
        }

        Map<Long, Talent> talentsById = talentRepository.findAllById(
                pendingMembers.stream().map(ProjectMember::getTalentId).distinct().toList()
        ).stream().collect(java.util.stream.Collectors.toMap(Talent::getId, t -> t, (a, b) -> a));

        List<MentorApplicationDTO> result = new ArrayList<>();
        for (ProjectMember member : pendingMembers) {
            Talent t = talentsById.get(member.getTalentId());
            String email = null;
            if (t != null) {
                email = userRepository.findById(t.getUserId()).map(User::getEmail).orElse(null);
            }
            List<String> skills = t != null
                    ? talentSkillRepository.findByTalentId(t.getId()).stream()
                        .map(s -> s.getSkillName())
                        .toList()
                    : List.of();

            result.add(MentorApplicationDTO.builder()
                    .memberId(member.getId())
                    .projectId(member.getProjectId())
                    .talentId(member.getTalentId())
                    .fullName(t != null ? t.getFullName() : null)
                    .studentId(t != null ? t.getStudentId() : null)
                    .email(email)
                    .status(member.getStatus() != null ? member.getStatus().name() : null)
                    .joinMessage(member.getJoinMessage())
                    .createdAt(member.getCreatedAt())
                    .skills(skills)
                    .build());
        }
        return result;
    }

    public void approveApplication(User user, long projectId, long memberId) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        ProjectMember member = projectMemberRepository.findById(memberId)
                .orElseThrow(() -> new ResourceNotFoundException("Application not found"));
        if (!member.getProjectId().equals(projectId)) {
            throw new ResourceNotFoundException("Application not found");
        }
        if (member.getStatus() != ProjectMember.MemberStatus.PENDING) {
            return;
        }

        member.setStatus(ProjectMember.MemberStatus.ACTIVE);
        member.setApprovedBy(mentor.getId());
        member.setApprovedAt(LocalDateTime.now());
        member.setJoinedAt(LocalDateTime.now());
        projectMemberRepository.save(member);

        Integer current = project.getCurrentMembersCount() != null ? project.getCurrentMembersCount() : 0;
        project.setCurrentMembersCount(current + 1);
        projectRepository.save(project);
    }

    public void rejectApplication(User user, long projectId, long memberId, String reason) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        ProjectMember member = projectMemberRepository.findById(memberId)
                .orElseThrow(() -> new ResourceNotFoundException("Application not found"));
        if (!member.getProjectId().equals(projectId)) {
            throw new ResourceNotFoundException("Application not found");
        }
        if (member.getStatus() != ProjectMember.MemberStatus.PENDING) {
            return;
        }

        member.setStatus(ProjectMember.MemberStatus.REJECTED);
        member.setApprovedBy(mentor.getId());
        member.setApprovedAt(LocalDateTime.now());
        projectMemberRepository.save(member);

        if (reason != null && !reason.isBlank()) {
            log.info("Mentor {} rejected application {}: {}", mentor.getId(), memberId, reason);
        }
    }

    public MentorTaskDTO createTask(User user, long projectId, MentorTaskUpsertRequest request) {
        Mentor mentor = requireMentor(user);

        MentorTask task = new MentorTask();
        task.setMentorId(mentor.getId());
        task.setProjectId(projectId);
        task.setTitle(requireNonBlank(request != null ? request.getTitle() : null, "title"));
        task.setDescription(request != null && request.getDescription() != null ? request.getDescription() : "");
        task.setStatus(normalizeStatus(request != null ? request.getStatus() : null));
        task.setProgress(normalizeProgress(request != null ? request.getProgress() : null));
        task.setAssignedTo(toJsonArray(request != null ? request.getAssignedTo() : null));
        task.setDueDate(parseLocalDate(request != null ? request.getDueDate() : null));
        task.setPriority(normalizePriority(request != null ? request.getPriority() : null));
        task.setProjectName(resolveProjectTitle(projectId));
        task.setCreatedAt(LocalDateTime.now());
        task.setUpdatedAt(LocalDateTime.now());

        MentorTask saved = mentorTaskRepository.save(task);
        return toTaskDTO(saved);
    }

    public MentorTaskDTO updateTask(User user, long projectId, long taskId, MentorTaskUpsertRequest request) {
        Mentor mentor = requireMentor(user);
        MentorTask task = mentorTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        if (!mentor.getId().equals(task.getMentorId()) || (task.getProjectId() != null && task.getProjectId() != projectId)) {
            throw new ResourceNotFoundException("Task not found");
        }

        if (request != null) {
            if (request.getTitle() != null && !request.getTitle().isBlank()) {
                task.setTitle(request.getTitle());
            }
            if (request.getDescription() != null) {
                task.setDescription(request.getDescription());
            }
            if (request.getStatus() != null) {
                task.setStatus(normalizeStatus(request.getStatus()));
            }
            if (request.getProgress() != null) {
                task.setProgress(normalizeProgress(request.getProgress()));
            }
            if (request.getAssignedTo() != null) {
                task.setAssignedTo(toJsonArray(request.getAssignedTo()));
            }
            if (request.getDueDate() != null) {
                task.setDueDate(parseLocalDate(request.getDueDate()));
            }
            if (request.getPriority() != null) {
                task.setPriority(normalizePriority(request.getPriority()));
            }
        }

        task.setUpdatedAt(LocalDateTime.now());
        MentorTask saved = mentorTaskRepository.save(task);
        return toTaskDTO(saved);
    }

    public void deleteTask(User user, long projectId, long taskId) {
        Mentor mentor = requireMentor(user);
        MentorTask task = mentorTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        if (!mentor.getId().equals(task.getMentorId()) || (task.getProjectId() != null && task.getProjectId() != projectId)) {
            throw new ResourceNotFoundException("Task not found");
        }
        mentorTaskRepository.delete(task);
    }

    public List<MentorTalentEvaluationDTO> getEvaluations(User user, Long projectId) {
        Mentor mentor = requireMentor(user);

        List<TalentEvaluation> items = (projectId != null)
                ? talentEvaluationRepository.findByMentorIdAndProjectIdOrderByCreatedAtDesc(mentor.getId(), projectId)
                : talentEvaluationRepository.findByMentorIdOrderByCreatedAtDesc(mentor.getId());

        if (items.isEmpty()) {
            return List.of();
        }

        List<Long> talentIds = items.stream().map(TalentEvaluation::getTalentId).distinct().toList();
        Map<Long, Talent> talents = talentRepository.findAllById(talentIds).stream()
                .collect(java.util.stream.Collectors.toMap(Talent::getId, t -> t, (a, b) -> a));

        List<MentorTalentEvaluationDTO> result = new ArrayList<>();
        for (TalentEvaluation e : items) {
            Talent t = talents.get(e.getTalentId());
            result.add(toEvaluationDTO(e, t));
        }
        return result;
    }

    public MentorTalentEvaluationDTO submitEvaluation(User user, long projectId, SubmitEvaluationRequest request) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));
        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        if (request == null || request.getTalentId() == null) {
            throw new IllegalArgumentException("Missing field: talentId");
        }
        String period = requireNonBlank(request.getEvaluationPeriod(), "evaluationPeriod");

        boolean isMember = projectDataService.getProjectMembers(projectId).stream()
            .anyMatch(m -> m.getTalentId() != null && m.getTalentId().equals(request.getTalentId()));
        if (!isMember) {
            throw new ResourceNotFoundException("Talent not found");
        }

        TalentEvaluation evaluation = talentEvaluationRepository
                .findByProjectIdAndTalentIdAndEvaluationPeriod(projectId, request.getTalentId(), period)
                .orElseGet(TalentEvaluation::new);

        evaluation.setProjectId(projectId);
        evaluation.setTalentId(request.getTalentId());
        evaluation.setMentorId(mentor.getId());
        evaluation.setEvaluationPeriod(period);
        evaluation.setOverallScore(normalizeScore(request.getOverallScore()));
        evaluation.setTechnicalSkills(toJsonObject(request.getTechnicalSkills()));
        evaluation.setProblemSolving(toJsonObject(request.getProblemSolving()));
        evaluation.setTeamwork(toJsonObject(request.getTeamwork()));
        evaluation.setCommunication(toJsonObject(request.getCommunication()));
        evaluation.setCodeQuality(toJsonObject(request.getCodeQuality()));
        evaluation.setPunctuality(toJsonObject(request.getPunctuality()));
        evaluation.setStrengths(toJsonArray(request.getStrengths()));
        evaluation.setWeaknesses(toJsonArray(request.getWeaknesses()));
        evaluation.setRecommendations(toJsonArray(request.getRecommendations()));
        evaluation.setTasksCompleted(request.getTasksCompleted());
        evaluation.setTasksTotal(request.getTasksTotal());
        evaluation.setHoursWorked(request.getHoursWorked());
        evaluation.setGrade(calculateGrade(evaluation.getOverallScore()));

        TalentEvaluation saved = talentEvaluationRepository.save(evaluation);

        Talent t = talentRepository.findById(saved.getTalentId()).orElse(null);
        return toEvaluationDTO(saved, t);
    }

    public List<MentorReportDTO> getReports(User user) {
        Mentor mentor = requireMentor(user);
        List<MentorReport> reports = mentorReportRepository.findByMentorIdOrderByDueDateDesc(mentor.getId());
        return reports.stream().map(r -> MentorReportDTO.builder()
                .id(String.valueOf(r.getId()))
                .student(r.getStudent())
                .studentId(r.getStudentId())
                .reportName(r.getReportName())
                .status(r.getStatus())
                .submittedDate(formatDate(r.getSubmittedDate()))
                .dueDate(formatDate(r.getDueDate()))
                .score(r.getScore())
                .fileSize(r.getFileSize())
                .fileName(extractFileName(r.getFilePath()))
                .build()).toList();
    }

    public MentorReportDTO submitReport(
            User user,
            Long projectId,
            String student,
            String studentId,
            String reportName,
            String submittedDate,
            String dueDate,
            String status,
            String summary,
            MultipartFile file
    ) {
        Mentor mentor = requireMentor(user);

        MentorReport r = new MentorReport();
        r.setMentorId(mentor.getId());
        r.setProjectId(projectId);
        r.setStudent(requireNonBlank(student, "student"));
        r.setStudentId(requireNonBlank(studentId, "studentId"));
        r.setReportName(requireNonBlank(reportName, "reportName"));
        r.setStatus(status != null && !status.isBlank() ? status : "submitted");
        r.setSubmittedDate(parseLocalDate(submittedDate));
        r.setDueDate(requireNonNull(parseLocalDate(dueDate), "dueDate"));
        r.setSummary(summary);

        if (file != null && !file.isEmpty()) {
            r.setFileSize(humanSize(file.getSize()));
            r.setFilePath(storeReportFile(mentor.getId(), projectId, file));
        }

        MentorReport saved = mentorReportRepository.save(r);
        return MentorReportDTO.builder()
                .id(String.valueOf(saved.getId()))
                .student(saved.getStudent())
                .studentId(saved.getStudentId())
                .reportName(saved.getReportName())
                .status(saved.getStatus())
                .submittedDate(formatDate(saved.getSubmittedDate()))
                .dueDate(formatDate(saved.getDueDate()))
                .score(saved.getScore())
                .fileSize(saved.getFileSize())
            .fileName(extractFileName(saved.getFilePath()))
                .build();
    }

    public Resource getReportFile(User user, long reportId) {
        Mentor mentor = requireMentor(user);
        MentorReport report = mentorReportRepository.findById(reportId)
                .orElseThrow(() -> new ResourceNotFoundException("Report not found"));
        if (!mentor.getId().equals(report.getMentorId())) {
            throw new ResourceNotFoundException("Report not found");
        }

        if (report.getFilePath() == null || report.getFilePath().isBlank()) {
            throw new ResourceNotFoundException("File not found");
        }

        try {
            Path file = Paths.get(report.getFilePath()).toAbsolutePath().normalize();

            String base = System.getProperty("java.io.tmpdir");
            Path allowedBase = Path.of(base, "labodc", "mentor-reports", String.valueOf(mentor.getId()))
                    .toAbsolutePath()
                    .normalize();

            if (!file.startsWith(allowedBase)) {
                throw new ResourceNotFoundException("File not found");
            }
            if (!Files.exists(file) || !Files.isRegularFile(file)) {
                throw new ResourceNotFoundException("File not found");
            }

            return new UrlResource(file.toUri());
        } catch (ResourceNotFoundException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Failed to read mentor report file {}: {}", reportId, e.getMessage());
            throw new ResourceNotFoundException("File not found");
        }
    }

    public List<MentorTaskSubmissionDTO> getTaskSubmissions(User user, long taskId) {
        Mentor mentor = requireMentor(user);
        MentorTask task = mentorTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        if (!mentor.getId().equals(task.getMentorId())) {
            throw new ResourceNotFoundException("Task not found");
        }

        List<MentorTaskSubmission> submissions = mentorTaskSubmissionRepository.findByTaskIdOrderBySubmittedAtDesc(taskId);
        if (submissions.isEmpty()) {
            return List.of();
        }

        List<Long> talentIds = submissions.stream().map(MentorTaskSubmission::getTalentId).distinct().toList();
        java.util.Map<Long, Talent> talentMap = talentRepository.findAllById(talentIds).stream()
                .collect(java.util.stream.Collectors.toMap(Talent::getId, t -> t, (a, b) -> a));

        return submissions.stream()
                .map(s -> {
                    Talent talent = talentMap.get(s.getTalentId());
                    return MentorTaskSubmissionDTO.builder()
                            .id(s.getId())
                            .taskId(s.getTaskId())
                            .talentId(s.getTalentId())
                            .talentName(talent != null ? talent.getFullName() : null)
                            .studentId(talent != null ? talent.getStudentId() : null)
                            .fileName(s.getFileName())
                            .fileSize(s.getFileSize())
                            .submittedAt(s.getSubmittedAt() != null ? s.getSubmittedAt().toString() : null)
                            .build();
                })
                .toList();
    }

    public Resource getTaskSubmissionFile(User user, long taskId, long submissionId) {
        Mentor mentor = requireMentor(user);
        MentorTask task = mentorTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        if (!mentor.getId().equals(task.getMentorId())) {
            throw new ResourceNotFoundException("Task not found");
        }

        MentorTaskSubmission submission = mentorTaskSubmissionRepository.findById(submissionId)
                .orElseThrow(() -> new ResourceNotFoundException("File not found"));
        if (!submission.getTaskId().equals(taskId)) {
            throw new ResourceNotFoundException("File not found");
        }

        if (submission.getFilePath() == null || submission.getFilePath().isBlank()) {
            throw new ResourceNotFoundException("File not found");
        }

        try {
            java.nio.file.Path file = java.nio.file.Paths.get(submission.getFilePath()).toAbsolutePath().normalize();
            String base = System.getProperty("java.io.tmpdir");
            java.nio.file.Path allowedBase = java.nio.file.Path.of(
                    base,
                    "labodc",
                    "task-submissions",
                    String.valueOf(taskId),
                    String.valueOf(submission.getTalentId())
            ).toAbsolutePath().normalize();

            if (!file.startsWith(allowedBase)) {
                throw new ResourceNotFoundException("File not found");
            }
            if (!java.nio.file.Files.exists(file) || !java.nio.file.Files.isRegularFile(file)) {
                throw new ResourceNotFoundException("File not found");
            }

            return new org.springframework.core.io.UrlResource(file.toUri());
        } catch (ResourceNotFoundException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Failed to read task submission file {}: {}", submissionId, e.getMessage());
            throw new ResourceNotFoundException("File not found");
        }
    }

    public void closeRecruiting(User user, long projectId) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));

        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        if (project.getStatus() != com.uth.labodc.model.enums.ProjectStatus.RECRUITING) {
            return;
        }

        project.setStatus(com.uth.labodc.model.enums.ProjectStatus.IN_PROGRESS);
        project.setAllowApplications(false);
        if (project.getActualStartDate() == null) {
            project.setActualStartDate(LocalDate.now());
        }
        projectRepository.save(project);
    }

    public int updateProjectProgress(User user, long projectId, Integer progress) {
        Mentor mentor = requireMentor(user);
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found"));

        if (project.getMentorId() == null || !project.getMentorId().equals(mentor.getId())) {
            throw new ResourceNotFoundException("Project not found");
        }

        if (progress == null) {
            throw new IllegalArgumentException("Missing field: progress");
        }

        int normalized = normalizeProgress(progress);
        project.setProgressPercentage(normalized);
        if (normalized >= 100) {
            project.setStatus(com.uth.labodc.model.enums.ProjectStatus.COMPLETED);
            if (project.getActualEndDate() == null) {
                project.setActualEndDate(LocalDate.now());
            }
        }
        project.setUpdatedAt(LocalDateTime.now());
        projectRepository.save(project);
        return normalized;
    }

    private MentorTaskDTO toTaskDTO(MentorTask t) {
        return MentorTaskDTO.builder()
                .id(String.valueOf(t.getId()))
                .projectId(t.getProjectId())
                .title(t.getTitle())
                .description(t.getDescription() != null ? t.getDescription() : "")
                .status(t.getStatus())
                .progress(t.getProgress() != null ? t.getProgress() : 0)
                .assignedTo(parseStringList(t.getAssignedTo()))
                .dueDate(formatDate(t.getDueDate()))
                .priority(normalizePriority(t.getPriority()))
                .projectName(t.getProjectName() != null ? t.getProjectName() : "")
                .build();
    }

    private String requireNonBlank(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Missing field: " + field);
        }
        return value;
    }

    private <T> T requireNonNull(T value, String field) {
        if (value == null) {
            throw new IllegalArgumentException("Missing field: " + field);
        }
        return value;
    }

    private String resolveProjectTitle(long projectId) {
        return projectRepository.findById(projectId).map(Project::getTitle).orElse("");
    }

    private String normalizeStatus(String status) {
        if (status == null) return "pending";
        String s = status.trim().toLowerCase();
        return switch (s) {
            case "pending", "in-progress", "completed" -> s;
            default -> "pending";
        };
    }

    private int normalizeProgress(Integer progress) {
        if (progress == null) return 0;
        return Math.max(0, Math.min(100, progress));
    }

    private String toJsonArray(List<String> list) {
        if (list == null) {
            return "[]";
        }
        try {
            return objectMapper.writeValueAsString(list);
        } catch (Exception e) {
            return "[]";
        }
    }

    private String toJsonObject(Map<String, Object> obj) {
        if (obj == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return null;
        }
    }

    private Map<String, Object> parseJsonObject(String json) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            return null;
        }
    }

    private List<String> parseJsonStringArray(String json) {
        if (json == null || json.isBlank()) {
            return List.of();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private Double normalizeScore(Double score) {
        if (score == null) return null;
        return Math.max(0.0, Math.min(10.0, score));
    }

    private String calculateGrade(Double overallScore) {
        if (overallScore == null) return null;
        if (overallScore >= 9.0) return "A";
        if (overallScore >= 8.0) return "B";
        if (overallScore >= 7.0) return "C";
        if (overallScore >= 6.0) return "D";
        return "F";
    }

    private MentorTalentEvaluationDTO toEvaluationDTO(TalentEvaluation e, Talent t) {
        return MentorTalentEvaluationDTO.builder()
                .id(e.getId())
                .projectId(e.getProjectId())
                .talentId(e.getTalentId())
                .fullName(t != null ? t.getFullName() : null)
                .studentId(t != null ? t.getStudentId() : null)
                .evaluationPeriod(e.getEvaluationPeriod())
                .overallScore(e.getOverallScore())
                .grade(e.getGrade())
                .technicalSkills(parseJsonObject(e.getTechnicalSkills()))
                .problemSolving(parseJsonObject(e.getProblemSolving()))
                .teamwork(parseJsonObject(e.getTeamwork()))
                .communication(parseJsonObject(e.getCommunication()))
                .codeQuality(parseJsonObject(e.getCodeQuality()))
                .punctuality(parseJsonObject(e.getPunctuality()))
                .strengths(parseJsonStringArray(e.getStrengths()))
                .weaknesses(parseJsonStringArray(e.getWeaknesses()))
                .recommendations(parseJsonStringArray(e.getRecommendations()))
                .tasksCompleted(e.getTasksCompleted())
                .tasksTotal(e.getTasksTotal())
                .hoursWorked(e.getHoursWorked())
                .createdAt(e.getCreatedAt())
                .build();
    }

    private LocalDate parseLocalDate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String v = value.trim();
        try {
            if (v.length() >= 10) {
                // Handles both YYYY-MM-DD and ISO strings like 2026-02-03T...
                return LocalDate.parse(v.substring(0, 10));
            }
            return LocalDate.parse(v);
        } catch (DateTimeParseException e) {
            try {
                Instant instant = Instant.parse(v);
                return instant.atZone(ZoneId.systemDefault()).toLocalDate();
            } catch (Exception ignored) {
                return null;
            }
        }
    }

    private String storeReportFile(Long mentorId, Long projectId, MultipartFile file) {
        try {
            String base = System.getProperty("java.io.tmpdir");
            Path dir = Path.of(base, "labodc", "mentor-reports", String.valueOf(mentorId), String.valueOf(projectId != null ? projectId : 0));
            Files.createDirectories(dir);
            String filename = sanitizeFilename(file.getOriginalFilename() != null ? file.getOriginalFilename() : "report.bin");
            Path target = dir.resolve(filename);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            return target.toAbsolutePath().toString();
        } catch (Exception e) {
            log.warn("Failed to store mentor report file: {}", e.getMessage());
            return null;
        }
    }

    private String extractFileName(String filePath) {
        if (filePath == null || filePath.isBlank()) {
            return null;
        }
        try {
            return Paths.get(filePath).getFileName().toString();
        } catch (Exception e) {
            return null;
        }
    }

    private String sanitizeFilename(String filename) {
        if (filename == null || filename.isBlank()) {
            return "report.bin";
        }

        String baseName;
        try {
            baseName = Paths.get(filename).getFileName().toString();
        } catch (Exception e) {
            baseName = filename;
        }

        baseName = baseName.replace("\\u0000", "");
        baseName = baseName.replaceAll("[\\\\/]+", "_");
        baseName = baseName.replaceAll("\\s+", " ").trim();
        if (baseName.isBlank()) {
            return "report.bin";
        }
        if (baseName.length() > 150) {
            baseName = baseName.substring(baseName.length() - 150);
        }
        return baseName;
    }

    private String humanSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        double kb = bytes / 1024.0;
        if (kb < 1024) return String.format(java.util.Locale.US, "%.1f KB", kb);
        double mb = kb / 1024.0;
        if (mb < 1024) return String.format(java.util.Locale.US, "%.1f MB", mb);
        double gb = mb / 1024.0;
        return String.format(java.util.Locale.US, "%.1f GB", gb);
    }

    private Mentor requireMentor(User user) {
        return mentorRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ Mentor"));
    }

    private int sumStudentsForMentorProjects(long mentorId) {
        List<Project> projects = projectRepository.findByMentorId(mentorId);
        int sum = 0;
        for (Project p : projects) {
            if (p.getNumberOfStudents() != null) {
                sum += p.getNumberOfStudents();
            }
        }
        return sum;
    }

    private Map<Long, String> loadProjectTitles(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return Collections.emptyMap();
        }
        List<Project> projects = projectRepository.findAllById(ids);
        return projects.stream().collect(java.util.stream.Collectors.toMap(Project::getId, Project::getTitle, (a, b) -> a));
    }

    private List<String> parseStringList(String jsonArray) {
        if (jsonArray == null || jsonArray.isBlank()) {
            return List.of();
        }
        try {
            return objectMapper.readValue(jsonArray, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private String normalizePriority(String priority) {
        if (priority == null) {
            return "medium";
        }
        String p = priority.trim().toLowerCase();
        return switch (p) {
            case "high", "medium", "low" -> p;
            default -> "medium";
        };
    }

    private String formatDate(LocalDate date) {
        return date != null ? date.toString() : null;
    }

    private List<MentorActivityDTO> buildRecentActivities(long mentorId) {
        List<MentorActivityDTO> items = new ArrayList<>();

        List<MentorInvitation> invs = mentorInvitationRepository.findByMentorIdOrderByReceivedDateDesc(mentorId);
        if (!invs.isEmpty()) {
            MentorInvitation inv = invs.get(0);
            items.add(MentorActivityDTO.builder()
                    .id("inv-" + inv.getId())
                    .action("Cập nhật lời mời dự án: " + (inv.getGroupName() != null ? inv.getGroupName() : ""))
                    .timeAgo(timeAgo(inv.getUpdatedAt() != null ? inv.getUpdatedAt() : inv.getCreatedAt()))
                    .type("info")
                    .build());
        }

        List<MentorReport> reports = mentorReportRepository.findByMentorIdOrderByDueDateDesc(mentorId);
        if (!reports.isEmpty()) {
            MentorReport r = reports.get(0);
            items.add(MentorActivityDTO.builder()
                    .id("rep-" + r.getId())
                    .action("Báo cáo: " + r.getReportName())
                    .timeAgo(timeAgo(r.getUpdatedAt()))
                    .type("success")
                    .build());
        }

        List<MentorTask> tasks = mentorTaskRepository.findByMentorIdOrderByDueDateAsc(mentorId);
        if (!tasks.isEmpty()) {
            MentorTask t = tasks.get(0);
            items.add(MentorActivityDTO.builder()
                    .id("task-" + t.getId())
                    .action("Task: " + t.getTitle())
                    .timeAgo(timeAgo(t.getUpdatedAt()))
                    .type("warning")
                    .build());
        }

        return items;
    }

    private String timeAgo(LocalDateTime time) {
        if (time == null) {
            return "";
        }
        Duration d = Duration.between(time, LocalDateTime.now());
        long minutes = Math.max(0, d.toMinutes());
        if (minutes < 1) return "vừa xong";
        if (minutes < 60) return minutes + " phút trước";
        long hours = minutes / 60;
        if (hours < 24) return hours + " giờ trước";
        long days = hours / 24;
        return days + " ngày trước";
    }
}
