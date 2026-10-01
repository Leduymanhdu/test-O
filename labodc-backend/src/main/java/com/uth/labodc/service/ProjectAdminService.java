package com.uth.labodc.service;

import com.uth.labodc.dto.ProjectDTO;
import com.uth.labodc.model.entity.*;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProjectAdminService {
    
    private final ProjectRepository projectRepository;
    private final ProjectTechnologyRepository projectTechnologyRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final MentorRepository mentorRepository;
    private final UserRepository userRepository;
    
    public User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }
    
    @Transactional(readOnly = true)
    public Page<ProjectDTO> getAllProjects(Pageable pageable) {
        return projectRepository.findAll(pageable)
                .map(this::convertToDTO);
    }
    
    @Transactional(readOnly = true)
    public ProjectDTO getProjectById(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
        return convertToDTO(project);
    }
    
    @Transactional
    public ProjectDTO createProject(ProjectDTO dto, Long userId) {
        log.info("Creating new project by user: {}", userId);
        
        Project project = new Project();
        project.setEnterpriseId(dto.getEnterpriseId());
        project.setMentorId(dto.getMentorId());
        project.setTitle(dto.getTitle());
        project.setSlug(generateSlug(dto.getTitle()));
        project.setDescription(dto.getDescription());
        project.setObjectives(dto.getObjectives());
        project.setRequirements(dto.getRequirements());
        project.setStartDate(dto.getStartDate());
        project.setEndDate(dto.getEndDate());
        project.setBudget(dto.getBudget() != null ? dto.getBudget().longValue() : null);
        project.setCurrency(dto.getCurrency());
        project.setNumberOfStudents(dto.getNumberOfStudents());
        project.setStatus(dto.getStatus() != null ? ProjectStatus.valueOf(dto.getStatus()) : ProjectStatus.DRAFT);
        project.setValidated("pending");
        project.setProgressPercentage(0);
        project.setCreatedAt(LocalDateTime.now());
        project.setUpdatedAt(LocalDateTime.now());
        
        Project saved = projectRepository.save(project);
        
        // Add technologies if provided
        if (dto.getTechnologies() != null) {
            for (String techName : dto.getTechnologies()) {
                ProjectTechnology tech = new ProjectTechnology();
                tech.setProjectId(saved.getId());
                tech.setTechnologyName(techName);
                tech.setCreatedAt(LocalDateTime.now());
                projectTechnologyRepository.save(tech);
            }
        }
        
        log.info("Project created with id: {}", saved.getId());
        return convertToDTO(saved);
    }
    
    @Transactional
    public ProjectDTO updateProject(Long id, ProjectDTO dto) {
        log.info("Updating project with id: {}", id);
        
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
        
        // Update only non-null fields to preserve existing values
        if (dto.getEnterpriseId() != null) {
            project.setEnterpriseId(dto.getEnterpriseId());
        }
        if (dto.getMentorId() != null) {
            project.setMentorId(dto.getMentorId());
        }
        if (dto.getTitle() != null && !dto.getTitle().isEmpty()) {
            project.setTitle(dto.getTitle());
        }
        if (dto.getDescription() != null) {
            project.setDescription(dto.getDescription());
        }
        if (dto.getObjectives() != null) {
            project.setObjectives(dto.getObjectives());
        }
        if (dto.getRequirements() != null) {
            project.setRequirements(dto.getRequirements());
        }
        if (dto.getStartDate() != null) {
            project.setStartDate(dto.getStartDate());
        }
        if (dto.getEndDate() != null) {
            project.setEndDate(dto.getEndDate());
        }
        if (dto.getBudget() != null) {
            project.setBudget(dto.getBudget().longValue());
        }
        if (dto.getCurrency() != null && !dto.getCurrency().isEmpty()) {
            project.setCurrency(dto.getCurrency());
        }
        if (dto.getNumberOfStudents() != null) {
            project.setNumberOfStudents(dto.getNumberOfStudents());
        }
        if (dto.getStatus() != null && !dto.getStatus().isEmpty()) {
            project.setStatus(ProjectStatus.valueOf(dto.getStatus()));
        }
        if (dto.getProgressPercentage() != null) {
            project.setProgressPercentage(dto.getProgressPercentage());
        }
        
        // Update validated field if provided
        if (dto.getValidated() != null && !dto.getValidated().isEmpty()) {
            project.setValidated(dto.getValidated().toLowerCase());
        }
        
        project.setUpdatedAt(LocalDateTime.now());
        
        Project saved = projectRepository.save(project);
        
        // Update technologies if provided
        if (dto.getTechnologies() != null) {
            // Delete existing technologies and flush to commit before inserting new ones
            List<ProjectTechnology> existingTechs = projectTechnologyRepository.findByProjectId(id);
            if (!existingTechs.isEmpty()) {
                projectTechnologyRepository.deleteAll(existingTechs);
                projectTechnologyRepository.flush();
            }

            for (String techName : dto.getTechnologies()) {
                ProjectTechnology tech = new ProjectTechnology();
                tech.setProjectId(id);
                tech.setTechnologyName(techName);
                tech.setCreatedAt(LocalDateTime.now());
                projectTechnologyRepository.save(tech);
            }
        }
        
        log.info("Project {} updated successfully", id);
        return convertToDTO(saved);
    }
    
    @Transactional
    public void deleteProject(Long id) {
        log.info("Deleting project with id: {}", id);
        
        // Delete related data first
        projectTechnologyRepository.deleteByProjectId(id);
        projectMemberRepository.deleteByProjectId(id);
        
        // Delete project
        projectRepository.deleteById(id);
        
        log.info("Project {} deleted successfully", id);
    }
    
    @Transactional
    public ProjectDTO validateProject(Long id, Long validatedBy) {
        log.info("Validating project with id: {} by user {}", id, validatedBy);
        
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
        
        project.setValidated("approved");
        project.setValidatedAt(LocalDateTime.now());
        project.setValidatedBy(validatedBy);
        project.setRejectionReason(null); // Clear any previous rejection reason
        if (project.getStatus() == null || project.getStatus() == ProjectStatus.PENDING_VALIDATION) {
            project.setStatus(ProjectStatus.RECRUITING);
        }
        
        Project saved = projectRepository.save(project);
        log.info("Project {} validated successfully", id);
        
        return convertToDTO(saved);
    }
    
    @Transactional
    public void rejectProject(Long id, Long rejectedBy, String reason) {
        log.info("Rejecting project with id: {} by user {}", id, rejectedBy);
        
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
        
        project.setValidated("rejected");
        project.setValidatedAt(LocalDateTime.now());
        project.setValidatedBy(rejectedBy);
        project.setRejectionReason(reason);
        
        projectRepository.save(project);
        log.info("Project {} rejected successfully with reason: {}", id, reason);
    }
    
    private ProjectDTO convertToDTO(Project project) {
        // Get enterprise name
        String enterpriseName = null;
        if (project.getEnterpriseId() != null) {
            enterpriseName = enterpriseRepository.findById(project.getEnterpriseId())
                    .map(Enterprise::getCompanyName)
                    .orElse(null);
        }
        
        // Get mentor name
        String mentorName = null;
        if (project.getMentorId() != null) {
            mentorName = mentorRepository.findById(project.getMentorId())
                    .map(Mentor::getFullName)
                    .orElse(null);
        }
        
        // Get validated by name
        String validatedByName = null;
        if (project.getValidatedBy() != null) {
            validatedByName = userRepository.findById(project.getValidatedBy())
                    .map(User::getEmail)
                    .orElse(null);
        }
        
        // Get technologies
        List<String> technologies = projectTechnologyRepository.findByProjectId(project.getId())
                .stream()
                .map(ProjectTechnology::getTechnologyName)
                .collect(Collectors.toList());
        
        String primaryTech = technologies.isEmpty() ? null : technologies.get(0);
        
        // Get project members
        List<ProjectMember> members = projectMemberRepository.findByProjectId(project.getId());
        List<Long> talentIds = members.stream()
                .map(ProjectMember::getTalentId)
                .collect(Collectors.toList());
        
        // TODO: Get talent names from talent IDs
        List<String> talentNames = List.of();
        
        // Calculate duration
        Integer durationWeeks = null;
        if (project.getStartDate() != null && project.getEndDate() != null) {
            long days = project.getEndDate().toEpochDay() - project.getStartDate().toEpochDay();
            durationWeeks = (int) (days / 7);
        }
        
        return ProjectDTO.builder()
                .id(project.getId())
                .enterpriseId(project.getEnterpriseId())
                .enterpriseName(enterpriseName)
                .mentorId(project.getMentorId())
                .mentorName(mentorName)
                .title(project.getTitle())
                .slug(project.getSlug())
                .description(project.getDescription())
                .objectives(project.getObjectives())
                .requirements(project.getRequirements())
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .durationWeeks(durationWeeks)
                .budget(project.getBudget() != null ? project.getBudget().doubleValue() : null)
                .currency(project.getCurrency())
                .numberOfStudents(project.getNumberOfStudents())
                .currentMembers(project.getCurrentMembersCount())
                .talentIds(talentIds)
                .talentNames(talentNames)
                .technologies(technologies)
                .primaryTechnology(primaryTech)
                .status(project.getStatus().name())
                .progressPercentage(project.getProgressPercentage())
                .validated(project.getValidated())
                .validatedAt(project.getValidatedAt())
                .validatedBy(project.getValidatedBy())
                .validatedByName(validatedByName)
                .totalMilestones(0) // TODO: implement milestone count
                .completedMilestones(0)
                .createdAt(project.getCreatedAt())
                .updatedAt(project.getUpdatedAt())
                .build();
    }
    
    private String generateSlug(String title) {
        if (title == null) return "";
        return title.toLowerCase()
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                .trim() + "-" + System.currentTimeMillis();
    }
}
