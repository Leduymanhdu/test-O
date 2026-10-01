package com.uth.labodc.service;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.talent.*;
import com.uth.labodc.model.entity.*;
import com.uth.labodc.model.entity.TalentSkill.SkillLevel;
import com.uth.labodc.model.entity.ProjectMember.MemberStatus;
import com.uth.labodc.repository.*;
import com.uth.labodc.dto.talent.TalentTaskSubmissionDTO;
import com.uth.labodc.model.entity.MentorTaskSubmission;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class TalentService {
    
    private final TalentRepository talentRepository;
    private final TalentSkillRepository talentSkillRepository;
    private final TalentCertificationRepository talentCertificationRepository;
    private final ProjectRepository projectRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final UserService userService;
    private final EnterpriseRepository enterpriseRepository;
    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final MentorTaskRepository mentorTaskRepository;
    private final MentorTaskSubmissionRepository mentorTaskSubmissionRepository;
    private final ObjectMapper objectMapper;
    // private final CloudinaryService cloudinaryService;
    
    @Transactional(readOnly = true)
    public TalentProfileDTO getProfile(Long userId) {
        Talent talent = getTalentByUserId(userId);
        return buildTalentProfileDTO(talent);
    }
    
    @Transactional
    public TalentProfileDTO updateProfile(Long userId, TalentProfileDTO profileDTO) {
        Talent talent = getTalentByUserId(userId);
        
        // Update basic info
        if (profileDTO.getFullName() != null) talent.setFullName(profileDTO.getFullName());
        if (profileDTO.getFaculty() != null) talent.setFaculty(profileDTO.getFaculty());
        if (profileDTO.getMajor() != null) talent.setMajor(profileDTO.getMajor());
        if (profileDTO.getYearOfStudy() != null) talent.setYearOfStudy(profileDTO.getYearOfStudy());
        if (profileDTO.getBio() != null) talent.setBio(profileDTO.getBio());
        if (profileDTO.getGpa() != null) talent.setGpa(profileDTO.getGpa());
        if (profileDTO.getDateOfBirth() != null) talent.setDateOfBirth(profileDTO.getDateOfBirth());
        if (profileDTO.getExpectedGraduation() != null) talent.setExpectedGraduation(profileDTO.getExpectedGraduation());
        if (profileDTO.getPortfolioUrl() != null) talent.setPortfolioUrl(profileDTO.getPortfolioUrl());
        if (profileDTO.getGithubUrl() != null) talent.setGithubUrl(profileDTO.getGithubUrl());
        if (profileDTO.getLinkedinUrl() != null) talent.setLinkedinUrl(profileDTO.getLinkedinUrl());
        if (profileDTO.getAvailableForProjects() != null) talent.setAvailableForProjects(profileDTO.getAvailableForProjects());
        if (profileDTO.getWorkAvailability() != null) talent.setWorkAvailability(profileDTO.getWorkAvailability());
        if (profileDTO.getHoursPerWeek() != null) talent.setHoursPerWeek(profileDTO.getHoursPerWeek());
        
        talent = talentRepository.save(talent);
        log.info("Updated talent profile for userId: {}", userId);
        
        return buildTalentProfileDTO(talent);
    }
    
    @Transactional
    public TalentSkillDTO addSkill(Long userId, TalentSkillDTO skillDTO) {
        Talent talent = getTalentByUserId(userId);
        
        // Check if skill already exists
        if (talentSkillRepository.findByTalentIdAndSkillName(talent.getId(), skillDTO.getSkillName()).isPresent()) {
            throw new IllegalArgumentException("Skill already exists: " + skillDTO.getSkillName());
        }
        
        TalentSkill skill = TalentSkill.builder()
                .talentId(talent.getId())
                .skillName(skillDTO.getSkillName())
                .skillCategory(skillDTO.getSkillCategory())
                .proficiencyLevel(skillDTO.getProficiencyLevel())
                .yearsOfExperience(skillDTO.getYearsOfExperience())
                .createdAt(LocalDateTime.now())
                .build();
                
        skill = talentSkillRepository.save(skill);
        log.info("Added skill '{}' for talent userId: {}", skillDTO.getSkillName(), userId);
        
        return mapToSkillDTO(skill);
    }
    
    @Transactional
    public void removeSkill(Long userId, Long skillId) {
        Talent talent = getTalentByUserId(userId);
        
        TalentSkill skill = talentSkillRepository.findById(skillId)
                .orElseThrow(() -> new IllegalArgumentException("Skill not found"));
                
        if (!skill.getTalentId().equals(talent.getId())) {
            throw new AccessDeniedException("You can only remove your own skills");
        }
        
        talentSkillRepository.delete(skill);
        log.info("Removed skill '{}' for talent userId: {}", skill.getSkillName(), userId);
    }
    
    @Transactional
    public TalentCertificationDTO addCertification(Long userId, TalentCertificationDTO certDTO) {
        Talent talent = getTalentByUserId(userId);
        
        TalentCertification cert = TalentCertification.builder()
                .talentId(talent.getId())
                .name(certDTO.getName())
                .issuer(certDTO.getIssuer())
                .issueDate(certDTO.getIssueDate())
                .expiryDate(certDTO.getExpiryDate())
                .credentialUrl(certDTO.getCredentialUrl())
                .description(certDTO.getDescription())
                .createdAt(LocalDateTime.now())
                .build();
                
        cert = talentCertificationRepository.save(cert);
        log.info("Added certification '{}' for talent userId: {}", certDTO.getName(), userId);
        
        return mapToCertificationDTO(cert);
    }
    
    @Transactional
    public ApiResponse<String> joinProject(Long userId, Long projectId, JoinProjectRequest request) {
        Talent talent = getTalentByUserId(userId);
        
        // Check if project exists and is recruiting
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new IllegalArgumentException("Project not found"));
                
        if (project.getStatus() != com.uth.labodc.model.enums.ProjectStatus.RECRUITING) {
            return ApiResponse.error("Project is not currently recruiting");
        }
        
        // Check if already applied/joined
        if (projectMemberRepository.existsByProjectIdAndTalentId(projectId, talent.getId())) {
            return ApiResponse.error("You have already applied to this project");
        }
        
        ProjectMember member = ProjectMember.builder()
                .projectId(projectId)
                .talentId(talent.getId())
                .status(MemberStatus.PENDING)
                .role(ProjectMember.MemberRole.MEMBER)
                .joinMessage(request.getMessage())
                .createdAt(LocalDateTime.now())
                .build();
                
        projectMemberRepository.save(member);
        log.info("Talent userId: {} applied to project: {}", userId, projectId);
        
        return ApiResponse.success("Successfully applied to project. Waiting for mentor approval.");
    }
    
    @Transactional(readOnly = true)
    public List<TalentProjectDTO> getMyProjects(Long userId) {
        Talent talent = getTalentByUserId(userId);
        
        List<ProjectMember> memberships = projectMemberRepository.findByTalentId(talent.getId());

        if (memberships.isEmpty()) {
            return List.of();
        }

        List<Long> projectIds = memberships.stream().map(ProjectMember::getProjectId).distinct().toList();
        List<Project> projects = projectRepository.findAllById(projectIds);
        java.util.Map<Long, Project> projectMap = projects.stream()
                .collect(Collectors.toMap(Project::getId, p -> p, (a, b) -> a));

        var techMap = loadTechnologies(projectIds);
        var skillMap = loadSkills(projectIds);

        return memberships.stream()
                .map(member -> {
                    Project project = projectMap.get(member.getProjectId());
                    if (project == null) {
                        return null;
                    }
                    TalentProjectDTO dto = mapProjectToTalentDTO(project, techMap.get(project.getId()), skillMap.get(project.getId()));
                    dto.setMemberStatus(member.getStatus() != null ? member.getStatus().name() : null);
                    dto.setMemberRole(member.getRole() != null ? member.getRole().name() : null);
                    return dto;
                })
                .filter(dto -> dto != null)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<TalentTaskDTO> getAssignedTasks(Long userId, Long projectId) {
        Talent talent = getTalentByUserId(userId);
        User user = userService.getUserById(talent.getUserId());

        List<ProjectMember> memberships = projectMemberRepository.findByTalentId(talent.getId());
        List<Long> activeProjectIds = memberships.stream()
                .filter(m -> m.getStatus() == MemberStatus.ACTIVE)
                .map(ProjectMember::getProjectId)
                .distinct()
                .toList();

        if (projectId != null) {
            if (!activeProjectIds.contains(projectId)) {
                return List.of();
            }
        }

        List<MentorTask> tasks = (projectId != null)
                ? mentorTaskRepository.findByProjectIdOrderByDueDateAsc(projectId)
                : (activeProjectIds.isEmpty() ? List.of() : mentorTaskRepository.findByProjectIdInOrderByDueDateAsc(activeProjectIds));

        if (tasks.isEmpty()) {
            return List.of();
        }

        List<String> identifiers = List.of(
                String.valueOf(talent.getId()),
                talent.getStudentId(),
                talent.getFullName(),
                user.getEmail()
        );

        return tasks.stream()
                .filter(task -> isAssignedToTalent(task, identifiers))
                .map(this::toTalentTaskDTO)
                .toList();
    }

    @Transactional
    public TalentTaskSubmissionDTO submitTaskReport(Long userId, Long taskId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is required");
        }

        Talent talent = getTalentByUserId(userId);
        User user = userService.getUserById(talent.getUserId());
        MentorTask task = mentorTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found"));

        if (task.getProjectId() != null) {
            ProjectMember membership = projectMemberRepository
                    .findByProjectIdAndTalentId(task.getProjectId(), talent.getId())
                    .orElse(null);
            if (membership == null || membership.getStatus() != MemberStatus.ACTIVE) {
                throw new AccessDeniedException("You are not an active member of this project");
            }
        }

        List<String> identifiers = List.of(
                String.valueOf(talent.getId()),
                talent.getStudentId(),
                talent.getFullName(),
                user.getEmail()
        );
        if (!isAssignedToTalent(task, identifiers)) {
            throw new AccessDeniedException("You are not assigned to this task");
        }

        StoredFileInfo stored = storeTaskSubmissionFile(talent.getId(), taskId, file);

        MentorTaskSubmission submission = new MentorTaskSubmission();
        submission.setTaskId(taskId);
        submission.setTalentId(talent.getId());
        submission.setFileName(stored.fileName());
        submission.setFilePath(stored.filePath());
        submission.setFileSize(stored.fileSize());
        submission.setSubmittedAt(LocalDateTime.now());

        MentorTaskSubmission saved = mentorTaskSubmissionRepository.save(submission);
        return TalentTaskSubmissionDTO.builder()
                .id(saved.getId())
                .taskId(saved.getTaskId())
                .fileName(saved.getFileName())
                .fileSize(saved.getFileSize())
                .submittedAt(saved.getSubmittedAt() != null ? saved.getSubmittedAt().toString() : null)
                .build();
    }

    @Transactional(readOnly = true)
    public TalentDashboardDTO getDashboard(Long userId) {
        Talent talent = getTalentByUserId(userId);

        List<ProjectMember> memberships = projectMemberRepository.findByTalentId(talent.getId());
        int totalProjects = memberships.size();
        int completed = (int) memberships.stream()
                .filter(m -> m.getStatus() == MemberStatus.INACTIVE)
                .count();
        int ongoing = (int) memberships.stream()
                .filter(m -> m.getStatus() == MemberStatus.ACTIVE)
                .count();

        int totalSkills = (int) talentSkillRepository.countByTalentId(talent.getId());
        int totalCerts = (int) talentCertificationRepository.countByTalentId(talent.getId());

        List<TalentProjectDTO> recentProjects = getMyProjects(userId).stream()
                .limit(5)
                .toList();

        TalentDashboardDTO.TalentStatsDTO stats = TalentDashboardDTO.TalentStatsDTO.builder()
                .totalProjects(totalProjects)
                .completedProjects(completed)
                .ongoingProjects(ongoing)
                .averageRating(talent.getRatingAverage())
                .totalSkills(totalSkills)
                .totalCertifications(totalCerts)
                .build();

        List<String> missingFields = new java.util.ArrayList<>();
        if (talent.getBio() == null || talent.getBio().isBlank()) missingFields.add("Bio");
        if (talent.getPortfolioUrl() == null || talent.getPortfolioUrl().isBlank()) missingFields.add("Portfolio URL");
        if (talent.getGithubUrl() == null || talent.getGithubUrl().isBlank()) missingFields.add("GitHub URL");
        if (talent.getLinkedinUrl() == null || talent.getLinkedinUrl().isBlank()) missingFields.add("LinkedIn URL");

        int totalFields = 4;
        int completedFields = totalFields - missingFields.size();
        int percentage = (int) Math.round((completedFields * 100.0) / totalFields);

        TalentDashboardDTO.ProfileCompletionDTO profileCompletion = TalentDashboardDTO.ProfileCompletionDTO.builder()
                .percentage(percentage)
                .missingFields(missingFields)
                .build();

        List<String> notifications = buildNotifications(memberships);

        return TalentDashboardDTO.builder()
                .stats(stats)
                .recentProjects(recentProjects)
                .upcomingTasks(List.of())
                .notifications(notifications)
                .profileCompletion(profileCompletion)
                .build();
    }

    @Transactional(readOnly = true)
    public TalentProjectPageDTO getAvailableProjects(Pageable pageable, String technology, BigDecimal minBudget, BigDecimal maxBudget, String sort) {
        List<Project> projects = projectRepository.findByStatusAndAllowApplicationsTrueAndIsPublicTrue(
                com.uth.labodc.model.enums.ProjectStatus.RECRUITING
        );

        List<Project> filtered = projects.stream()
                .filter(p -> minBudget == null || (p.getBudget() != null && BigDecimal.valueOf(p.getBudget()).compareTo(minBudget) >= 0))
                .filter(p -> maxBudget == null || (p.getBudget() != null && BigDecimal.valueOf(p.getBudget()).compareTo(maxBudget) <= 0))
                .toList();

        List<Long> ids = filtered.stream().map(Project::getId).toList();
        var techMap = loadTechnologies(ids);
        var skillMap = loadSkills(ids);

        List<Project> filteredByTech = (technology == null || technology.isBlank())
                ? filtered
                : filtered.stream()
                    .filter(p -> {
                        List<String> techs = techMap.get(p.getId());
                        if (techs == null) return false;
                        return techs.stream().anyMatch(t -> t != null && t.toLowerCase().contains(technology.toLowerCase()));
                    })
                    .toList();

        List<TalentProjectDTO> mapped = filteredByTech.stream()
                .map(p -> mapProjectToTalentDTO(p, techMap.get(p.getId()), skillMap.get(p.getId())))
                .toList();

        int page = pageable != null ? pageable.getPageNumber() : 0;
        int size = pageable != null ? pageable.getPageSize() : Math.max(mapped.size(), 1);
        int from = Math.min(page * size, mapped.size());
        int to = Math.min(from + size, mapped.size());
        List<TalentProjectDTO> content = mapped.subList(from, to);

        int totalPages = size == 0 ? 1 : (int) Math.ceil(mapped.size() / (double) size);

        return TalentProjectPageDTO.builder()
                .content(content)
                .totalElements(mapped.size())
                .totalPages(totalPages)
                .size(size)
                .number(page)
                .build();
    }

    @Transactional(readOnly = true)
    public TalentProjectDTO getProjectDetail(Long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new IllegalArgumentException("Project not found"));
        return mapProjectToTalentDTO(project, loadTechnologies(List.of(projectId)).get(projectId),
                loadSkills(List.of(projectId)).get(projectId));
    }
    
    // Helper methods
    
    private Talent getTalentByUserId(Long userId) {
        return talentRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Talent profile not found for user: " + userId));
    }
    
    private TalentProfileDTO buildTalentProfileDTO(Talent talent) {
        List<TalentSkillDTO> skills = talentSkillRepository.findByTalentId(talent.getId())
                .stream()
                .map(this::mapToSkillDTO)
                .collect(Collectors.toList());
                
        List<TalentCertificationDTO> certifications = talentCertificationRepository.findByTalentId(talent.getId())
                .stream()
                .map(this::mapToCertificationDTO)
                .collect(Collectors.toList());
        
        User user = userService.getUserById(talent.getUserId());
        
        return TalentProfileDTO.builder()
                .id(talent.getId())
                .fullName(talent.getFullName())
                .studentId(talent.getStudentId())
                .faculty(talent.getFaculty())
                .major(talent.getMajor())
                .yearOfStudy(talent.getYearOfStudy())
                .email(user.getEmail())
                .bio(talent.getBio())
                .gpa(talent.getGpa())
                .dateOfBirth(talent.getDateOfBirth())
                .expectedGraduation(talent.getExpectedGraduation())
                .portfolioUrl(talent.getPortfolioUrl())
                .githubUrl(talent.getGithubUrl())
                .linkedinUrl(talent.getLinkedinUrl())
                .availableForProjects(talent.getAvailableForProjects())
                .workAvailability(talent.getWorkAvailability())
                .hoursPerWeek(talent.getHoursPerWeek())
                .skills(skills)
                .certifications(certifications)
                .projectsCompleted(talent.getCompletedProjects())
                .averageRating(talent.getRatingAverage())
                .status("ACTIVE")
                .build();
    }
    
    private TalentSkillDTO mapToSkillDTO(TalentSkill skill) {
        return TalentSkillDTO.builder()
                .id(skill.getId())
                .skillName(skill.getSkillName())
                .skillCategory(skill.getSkillCategory())
                .proficiencyLevel(skill.getProficiencyLevel())
                .yearsOfExperience(skill.getYearsOfExperience())
                .build();
    }
    
    private TalentCertificationDTO mapToCertificationDTO(TalentCertification cert) {
        return TalentCertificationDTO.builder()
                .id(cert.getId())
                .name(cert.getName())
                .issuer(cert.getIssuer())
                .issueDate(cert.getIssueDate())
                .expiryDate(cert.getExpiryDate())
                .credentialUrl(cert.getCredentialUrl())
                .description(cert.getDescription())
                .build();
    }
    
    private TalentProjectDTO mapToProjectDTO(Project project) {
        return TalentProjectDTO.builder()
                .id(project.getId())
                .title(project.getTitle())
                .description(project.getDescription())
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .budget(project.getBudget() != null ? BigDecimal.valueOf(project.getBudget()) : null)
                .status(project.getStatus() != null ? project.getStatus().name() : null)
                .build();
    }

    public String storeAvatar(Long userId, MultipartFile file) {
        return storeTalentFile(userId, file, "avatar");
    }

    public String storeCv(Long userId, MultipartFile file) {
        return storeTalentFile(userId, file, "cv");
    }

    private String storeTalentFile(Long userId, MultipartFile file, String category) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File is required");
        }
        try {
            String base = System.getProperty("java.io.tmpdir");
            java.nio.file.Path dir = java.nio.file.Path.of(base, "labodc", "talent", String.valueOf(userId), category);
            java.nio.file.Files.createDirectories(dir);
            String filename = sanitizeFilename(file.getOriginalFilename() != null ? file.getOriginalFilename() : category + ".bin");
            java.nio.file.Path target = dir.resolve(filename);
            java.nio.file.Files.copy(file.getInputStream(), target, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            return target.toAbsolutePath().toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to store file: " + e.getMessage());
        }
    }

    private String sanitizeFilename(String filename) {
        String baseName = filename.replace("\\u0000", "");
        baseName = baseName.replaceAll("[\\\\/]+", "_");
        baseName = baseName.replaceAll("\\s+", " ").trim();
        if (baseName.isBlank()) {
            return "file.bin";
        }
        if (baseName.length() > 150) {
            baseName = baseName.substring(baseName.length() - 150);
        }
        return baseName;
    }

    private List<TalentProjectDTO> mapProjectsToTalentDTO(List<Project> projects) {
        if (projects == null || projects.isEmpty()) {
            return List.of();
        }
        List<Long> ids = projects.stream().map(Project::getId).toList();
        var techMap = loadTechnologies(ids);
        var skillMap = loadSkills(ids);

        return projects.stream()
                .map(p -> mapProjectToTalentDTO(p, techMap.get(p.getId()), skillMap.get(p.getId())))
                .toList();
    }

    private TalentProjectDTO mapProjectToTalentDTO(Project project, List<String> techs, List<String> skills) {
        TalentProjectDTO.CompanyInfo company = null;
        if (project.getEnterpriseId() != null) {
            company = enterpriseRepository.findById(project.getEnterpriseId())
                    .map(e -> TalentProjectDTO.CompanyInfo.builder().name(e.getCompanyName()).build())
                    .orElse(null);
        }
        return TalentProjectDTO.builder()
                .id(project.getId())
                .title(project.getTitle())
                .description(project.getDescription())
                .company(company)
                .technologies(techs != null ? techs : List.of())
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .budget(project.getBudget() != null ? BigDecimal.valueOf(project.getBudget()) : null)
                .numberOfStudents(project.getNumberOfStudents())
                .skillRequirements(skills != null ? skills : List.of())
                .status(project.getStatus() != null ? project.getStatus().name() : null)
                .build();
    }

    private java.util.Map<Long, List<String>> loadTechnologies(List<Long> projectIds) {
        if (projectIds == null || projectIds.isEmpty()) return java.util.Map.of();
        String sql = "SELECT project_id, technology_name FROM project_technologies WHERE project_id IN (:ids) ORDER BY technology_name";
        java.util.Map<Long, List<String>> result = new java.util.LinkedHashMap<>();
        jdbcTemplate.query(sql, java.util.Map.of("ids", projectIds), (rs, rowNum) -> {
            long projectId = rs.getLong("project_id");
            String value = rs.getString("technology_name");
            result.computeIfAbsent(projectId, k -> new java.util.ArrayList<>()).add(value);
            return null;
        });
        return result;
    }

    private java.util.Map<Long, List<String>> loadSkills(List<Long> projectIds) {
        if (projectIds == null || projectIds.isEmpty()) return java.util.Map.of();
        String sql = "SELECT project_id, skill_name FROM project_skill_requirements WHERE project_id IN (:ids) ORDER BY priority, skill_name";
        java.util.Map<Long, List<String>> result = new java.util.LinkedHashMap<>();
        jdbcTemplate.query(sql, java.util.Map.of("ids", projectIds), (rs, rowNum) -> {
            long projectId = rs.getLong("project_id");
            String value = rs.getString("skill_name");
            result.computeIfAbsent(projectId, k -> new java.util.ArrayList<>()).add(value);
            return null;
        });
        return result;
    }

    private List<String> buildNotifications(List<ProjectMember> memberships) {
        if (memberships == null || memberships.isEmpty()) {
            return List.of();
        }

        List<ProjectMember> decided = memberships.stream()
                .filter(m -> m.getApprovedAt() != null)
                .filter(m -> m.getStatus() == MemberStatus.ACTIVE || m.getStatus() == MemberStatus.REJECTED)
                .sorted((a, b) -> b.getApprovedAt().compareTo(a.getApprovedAt()))
                .limit(5)
                .toList();

        if (decided.isEmpty()) {
            return List.of();
        }

        List<Long> projectIds = decided.stream().map(ProjectMember::getProjectId).distinct().toList();
        java.util.Map<Long, Project> projectMap = projectRepository.findAllById(projectIds).stream()
                .collect(java.util.stream.Collectors.toMap(Project::getId, p -> p, (a, b) -> a));

        List<String> notifications = new java.util.ArrayList<>();
        for (ProjectMember member : decided) {
            Project project = projectMap.get(member.getProjectId());
            String title = project != null ? project.getTitle() : ("Project #" + member.getProjectId());
            if (member.getStatus() == MemberStatus.ACTIVE) {
                notifications.add("Đơn tham gia dự án \"" + title + "\" đã được duyệt.");
            } else if (member.getStatus() == MemberStatus.REJECTED) {
                notifications.add("Đơn tham gia dự án \"" + title + "\" đã bị từ chối.");
            }
        }
        return notifications;
    }

    private boolean isAssignedToTalent(MentorTask task, List<String> identifiers) {
        if (task == null) {
            return false;
        }
        List<String> assigned = parseAssignedTo(task.getAssignedTo());
        if (assigned.isEmpty()) {
            return false;
        }
        List<String> normalizedAssigned = assigned.stream()
                .filter(a -> a != null && !a.isBlank())
                .map(this::normalizeAssigned)
                .toList();

        for (String id : identifiers) {
            if (id == null || id.isBlank()) {
                continue;
            }
            String normalizedId = normalizeAssigned(id);
            for (String assignedValue : normalizedAssigned) {
                if (assignedValue.equals(normalizedId) || assignedValue.contains(normalizedId) || normalizedId.contains(assignedValue)) {
                    return true;
                }
            }
        }
        return false;
    }

    private List<String> parseAssignedTo(String json) {
        if (json == null || json.isBlank()) {
            return List.of();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private String normalizeAssigned(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    private StoredFileInfo storeTaskSubmissionFile(Long talentId, Long taskId, MultipartFile file) {
        try {
            String base = System.getProperty("java.io.tmpdir");
            java.nio.file.Path dir = java.nio.file.Path.of(
                    base,
                    "labodc",
                    "task-submissions",
                    String.valueOf(taskId),
                    String.valueOf(talentId)
            );
            java.nio.file.Files.createDirectories(dir);
            String filename = sanitizeFilename(file.getOriginalFilename() != null ? file.getOriginalFilename() : "submission.bin");
            java.nio.file.Path target = dir.resolve(filename);
            java.nio.file.Files.copy(file.getInputStream(), target, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            return new StoredFileInfo(filename, target.toAbsolutePath().toString(), file.getSize());
        } catch (Exception e) {
            throw new RuntimeException("Failed to store file: " + e.getMessage());
        }
    }

    private record StoredFileInfo(String fileName, String filePath, long fileSize) {}

    private TalentTaskDTO toTalentTaskDTO(MentorTask task) {
        return TalentTaskDTO.builder()
                .id(task.getId())
                .projectId(task.getProjectId())
                .title(task.getTitle())
                .description(task.getDescription())
                .status(task.getStatus())
                .progress(task.getProgress())
                .dueDate(task.getDueDate())
                .priority(task.getPriority())
                .projectName(task.getProjectName())
                .assignedTo(parseAssignedTo(task.getAssignedTo()))
                .build();
    }
}
