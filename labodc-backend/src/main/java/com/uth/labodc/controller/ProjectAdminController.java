package com.uth.labodc.controller;

import com.uth.labodc.dto.ProjectDTO;
import com.uth.labodc.service.ProjectAdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/lab-admin/projects")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
public class ProjectAdminController {
    
    private final ProjectAdminService projectAdminService;
    
    @GetMapping
    public ResponseEntity<Page<ProjectDTO>> getAllProjects(Pageable pageable) {
        log.info("Fetching all projects with pagination: {}", pageable);
        Page<ProjectDTO> projects = projectAdminService.getAllProjects(pageable);
        return ResponseEntity.ok(projects);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ProjectDTO> getProjectById(@PathVariable Long id) {
        log.info("Fetching project with id: {}", id);
        ProjectDTO project = projectAdminService.getProjectById(id);
        return ResponseEntity.ok(project);
    }
    
    @PostMapping
    public ResponseEntity<ProjectDTO> createProject(
            @RequestBody ProjectDTO dto) {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        log.info("Creating new project by user: {}", userEmail);
        
        // Get userId from userEmail
        com.uth.labodc.model.entity.User user = projectAdminService.findUserByEmail(userEmail);
        ProjectDTO created = projectAdminService.createProject(dto, user.getId());
        return ResponseEntity.ok(created);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ProjectDTO> updateProject(
            @PathVariable Long id,
            @RequestBody ProjectDTO dto) {
        log.info("Updating project with id: {}", id);
        ProjectDTO updated = projectAdminService.updateProject(id, dto);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProject(@PathVariable Long id) {
        log.info("Deleting project with id: {}", id);
        projectAdminService.deleteProject(id);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{id}/validate")
    public ResponseEntity<ProjectDTO> validateProject(@PathVariable Long id) {
        log.info("Validating project {}", id);
        
        // Get authenticated user
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        com.uth.labodc.model.entity.User user = projectAdminService.findUserByEmail(authentication.getName());
        
        ProjectDTO validated = projectAdminService.validateProject(id, user.getId());
        return ResponseEntity.ok(validated);
    }
    
    @PostMapping("/{id}/reject")
    public ResponseEntity<?> rejectProject(
            @PathVariable Long id,
            @RequestParam String reason) {
        log.info("Rejecting project {} with reason: {}", id, reason);
        
        // Get authenticated user
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        com.uth.labodc.model.entity.User user = projectAdminService.findUserByEmail(authentication.getName());
        
        projectAdminService.rejectProject(id, user.getId(), reason);
        return ResponseEntity.ok().build();
    }
}
