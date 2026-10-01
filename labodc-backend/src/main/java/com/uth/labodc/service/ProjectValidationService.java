package com.uth.labodc.service;

import com.uth.labodc.dto.project.*;
import com.uth.labodc.model.entity.Enterprise;
import com.uth.labodc.model.entity.MentorInvitation;
import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.EnterpriseRepository;
import com.uth.labodc.repository.MentorInvitationRepository;
import com.uth.labodc.repository.ProjectRepository;
import com.uth.labodc.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectValidationService {
    
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    private final MentorInvitationRepository mentorInvitationRepository;
    private final EnterpriseRepository enterpriseRepository;
    
    /**
     * Get validation statistics
     */
    public ProjectValidationStatsDTO getValidationStats() {
        LocalDateTime startOfMonth = LocalDateTime.now().with(TemporalAdjusters.firstDayOfMonth()).withHour(0).withMinute(0).withSecond(0);
        
        long totalPending = projectRepository.countByValidated("pending");
        long totalApproved = projectRepository.countByValidated("approved");
        long totalRejected = projectRepository.countByValidated("rejected");
        long totalValidated = totalApproved + totalRejected;
        long thisMonth = projectRepository.countByCreatedAtAfter(startOfMonth);
        
        return ProjectValidationStatsDTO.builder()
                .totalPending(totalPending)
                .totalApproved(totalApproved)
                .totalRejected(totalRejected)
                .totalValidated(totalValidated)
                .thisMonth(thisMonth)
                .build();
    }
    
    /**
     * Get projects for validation with optional status filter
     */
    public List<ProjectValidationDTO> getProjectsForValidation(String statusFilter) {
        List<Project> projects;
        
        if ("PENDING".equalsIgnoreCase(statusFilter)) {
            projects = projectRepository.findByValidatedAndStatusNot("pending", ProjectStatus.CANCELLED);
        } else if ("APPROVED".equalsIgnoreCase(statusFilter)) {
            projects = projectRepository.findByValidatedAndStatusNot("approved", ProjectStatus.CANCELLED);
        } else if ("REJECTED".equalsIgnoreCase(statusFilter)) {
            projects = projectRepository.findByValidatedAndStatusNot("rejected", ProjectStatus.CANCELLED);
        } else {
            // All projects
            projects = projectRepository.findAll();
        }
        
        return projects.stream()
                .map(this::mapToValidationDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Get project details by ID
     */
    public Project getProjectById(Long id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
    }
    
    /**
     * Approve project
     */
    @Transactional
    public Project approveProject(Long projectId, Long adminId, ApproveProjectRequest request) {
        log.info("Approving project {} by admin {}", projectId, adminId);
        
        Project project = getProjectById(projectId);
        
        // Apply adjustments if provided
        if (request.getAdjustments() != null) {
            if (request.getAdjustments().getNumberOfStudents() != null) {
                project.setNumberOfStudents(request.getAdjustments().getNumberOfStudents());
                log.info("Adjusted number of students to {}", request.getAdjustments().getNumberOfStudents());
            }
            if (request.getAdjustments().getDuration() != null) {
                // Parse duration and update dates if needed
                log.info("Adjusted duration to {}", request.getAdjustments().getDuration());
            }
        }
        
        // Update validation status
        project.setValidated("approved");
        project.setStatus(ProjectStatus.RECRUITING);
        project.setValidatedBy(adminId);
        project.setValidatedAt(LocalDateTime.now());
        project.setUpdatedAt(LocalDateTime.now());
        
        Project saved = projectRepository.save(project);
        log.info("Project {} approved successfully", projectId);
        
        return saved;
    }
    
    /**
     * Reject project
     */
    @Transactional
    public void rejectProject(Long projectId, Long adminId, RejectProjectRequest request) {
        log.info("Rejecting project {} by admin {}", projectId, adminId);
        
        Project project = getProjectById(projectId);
        
        // Delete project and save rejection record (reusing existing method)
        String reason = request.getReason() + ": " + request.getDetails();
        
        // Update status instead of deleting
        project.setStatus(ProjectStatus.REJECTED);
        project.setValidated("rejected");
        project.setValidatedBy(adminId);
        project.setValidatedAt(LocalDateTime.now());
        project.setUpdatedAt(LocalDateTime.now());
        
        projectRepository.save(project);
        
        log.info("Project {} rejected successfully", projectId);
    }
    
    /**
     * Assign mentor to project
     */
    @Transactional
    public Project assignMentor(Long projectId, Long mentorId, String message) {
        log.info("Assigning mentor {} to project {}", mentorId, projectId);
        
        Project project = getProjectById(projectId);
        User mentor = userRepository.findById(mentorId)
                .orElseThrow(() -> new RuntimeException("Mentor not found with id: " + mentorId));
        
        // Assign mentor
        project.setMentorId(mentorId);
        project.setUpdatedAt(LocalDateTime.now());
        
        Project saved = projectRepository.save(project);
        upsertMentorInvitation(saved, mentorId, message);
        log.info("Mentor {} assigned to project {} successfully", mentorId, projectId);
        
        return saved;
    }

    private void upsertMentorInvitation(Project project, Long mentorId, String message) {
        if (project == null || mentorId == null) {
            return;
        }

        MentorInvitation invitation = mentorInvitationRepository
                .findByMentorIdAndProjectId(mentorId, project.getId())
                .orElseGet(MentorInvitation::new);

        Long invitedBy = 1L;
        if (project.getEnterpriseId() != null) {
            Enterprise enterprise = enterpriseRepository.findById(project.getEnterpriseId()).orElse(null);
            if (enterprise != null && enterprise.getUserId() != null) {
                invitedBy = enterprise.getUserId();
            }
        }

        LocalDateTime now = LocalDateTime.now();
        invitation.setMentorId(mentorId);
        invitation.setProjectId(project.getId());
        invitation.setInvitedBy(invitedBy);
        invitation.setGroupName(project.getTitle() != null ? project.getTitle() : "Project #" + project.getId());
        invitation.setStudentCount(project.getNumberOfStudents() != null ? project.getNumberOfStudents() : 0);
        invitation.setDescription(project.getDescription());
        invitation.setDeadline(project.getStartDate());
        invitation.setExpiresAt(now.plusDays(7));
        invitation.setSkills("[]");
        invitation.setReceivedDate(LocalDate.now());
        invitation.setPriority("medium");
        invitation.setStatus("PENDING");
        if (invitation.getCreatedAt() == null) {
            invitation.setCreatedAt(now);
        }
        invitation.setUpdatedAt(now);

        mentorInvitationRepository.save(invitation);
        if (message != null && !message.isBlank()) {
            log.info("Mentor invitation message: {}", message);
        }
    }
    
    /**
     * Map Project entity to ProjectValidationDTO
     */
    private ProjectValidationDTO mapToValidationDTO(Project project) {
        // Note: Project entity only has enterpriseId, not full Enterprise object
        // Frontend will need to fetch enterprise details separately if needed
        
        return ProjectValidationDTO.builder()
                .id(project.getId())
                .title(project.getTitle())
                .description(project.getDescription())
                .enterprise(null) // Will be populated by frontend if needed
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .duration(null) // Calculate if needed
                .budget(project.getBudget() != null ? BigDecimal.valueOf(project.getBudget()) : BigDecimal.ZERO)
                .numberOfStudents(project.getNumberOfStudents())
                .status(project.getStatus().name())
                .submittedAt(project.getCreatedAt())
                .feasibilityScore(null) // Add if available
                .validated(project.getValidated())
                .build();
    }
}
