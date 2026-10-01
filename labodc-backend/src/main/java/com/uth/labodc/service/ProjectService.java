package com.uth.labodc.service;

import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.entity.ProjectRejection;
import com.uth.labodc.repository.ProjectRepository;
import com.uth.labodc.repository.ProjectRejectionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class ProjectService {
    
    private final ProjectRepository projectRepository;
    private final ProjectRejectionRepository projectRejectionRepository;
    
    @Transactional(readOnly = true)
    public Project findById(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Project not found with id: " + id));
        
        // Load rejection info if project was rejected
        if ("rejected".equals(project.getValidated())) {
            List<ProjectRejection> rejections = projectRejectionRepository
                    .findByProjectIdOrderByRejectedAtDesc(id);
            if (!rejections.isEmpty()) {
                ProjectRejection latestRejection = rejections.get(0);
                project.setRejectionReason(latestRejection.getRejectionReason());
                project.setRejectedAt(latestRejection.getRejectedAt());
                project.setRejectedBy(latestRejection.getRejectedBy());
            }
        }
        
        return project;
    }
    
    @Transactional(readOnly = true)
    public List<Project> findAll() {
        return projectRepository.findAll();
    }
    
    @Transactional
    public Project validateProject(Long id, Long validatedBy) {
        log.info("Approving project with id: {}", id);
        
        Project project = findById(id);
        
        if ("approved".equals(project.getValidated())) {
            throw new RuntimeException("Project is already approved");
        }
        
        project.setValidated("approved");
        project.setValidatedAt(LocalDateTime.now());
        project.setValidatedBy(validatedBy);
        if (project.getStatus() == null || project.getStatus() == com.uth.labodc.model.enums.ProjectStatus.PENDING_VALIDATION) {
            project.setStatus(com.uth.labodc.model.enums.ProjectStatus.RECRUITING);
        }
        
        Project saved = projectRepository.save(project);
        log.info("Project {} approved successfully", id);
        
        return saved;
    }
    
    @Transactional
    public Project rejectProject(Long id, Long rejectedBy, String reason) {
        log.info("Rejecting project with id: {} by admin: {}, reason: {}", id, rejectedBy, reason);
        
        Project project = findById(id);
        
        if ("rejected".equals(project.getValidated())) {
            throw new RuntimeException("Project is already rejected");
        }
        
        // Get enterprise name if available
        String enterpriseName = "";
        try {
            enterpriseName = "Enterprise #" + project.getEnterpriseId();
        } catch (Exception e) {
            log.warn("Could not fetch enterprise name for project {}", id);
        }
        
        // Save rejection record
        ProjectRejection rejection = ProjectRejection.builder()
                .projectId(id)
                .rejectedBy(rejectedBy)
                .rejectionReason(reason)
                .rejectedAt(LocalDateTime.now())
                .title(project.getTitle())
                .slug(project.getSlug())
                .enterpriseName(enterpriseName)
                .build();
        
        projectRejectionRepository.save(rejection);
        log.info("Rejection record saved for project {} ({})", id, project.getTitle());
        
        // Update project status to rejected (DO NOT DELETE)
        project.setValidated("rejected");
        project.setValidatedAt(LocalDateTime.now());
        project.setValidatedBy(rejectedBy);
        
        Project saved = projectRepository.save(project);
        log.info("Project {} rejected successfully (data preserved)", id);
        
        return saved;
    }
}
