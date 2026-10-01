package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.project.*;
import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.UserRepository;
import com.uth.labodc.service.ProjectValidationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/lab-admin/project-validation")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ProjectValidationController {
    
    private final ProjectValidationService projectValidationService;
    private final UserRepository userRepository;
    
    /**
     * Get validation statistics
     */
    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<ProjectValidationStatsDTO>> getValidationStats() {
        log.info("Fetching project validation statistics");
        ProjectValidationStatsDTO stats = projectValidationService.getValidationStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    /**
     * Get projects for validation
     */
    @GetMapping("/projects")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<ProjectValidationDTO>>> getProjectsForValidation(
            @RequestParam(required = false) String status) {
        log.info("Fetching projects for validation, status filter: {}", status);
        List<ProjectValidationDTO> projects = projectValidationService.getProjectsForValidation(status);
        return ResponseEntity.ok(ApiResponse.success(projects));
    }
    
    /**
     * Get project details by ID
     */
    @GetMapping("/projects/{id}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<Project>> getProjectById(@PathVariable Long id) {
        log.info("Fetching project details for id: {}", id);
        Project project = projectValidationService.getProjectById(id);
        return ResponseEntity.ok(ApiResponse.success(project));
    }
    
    /**
     * Approve project
     */
    @PostMapping("/projects/{id}/approve")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<Project>> approveProject(
            @PathVariable Long id,
            @RequestBody ApproveProjectRequest request,
            Authentication authentication) {
        log.info("Admin {} approving project {}", authentication.getName(), id);
        
        Long adminId = currentUser(authentication).getId();
        Project approved = projectValidationService.approveProject(id, adminId, request);
        
        return ResponseEntity.ok(ApiResponse.success("Project approved successfully", approved));
    }
    
    /**
     * Reject project
     */
    @PostMapping("/projects/{id}/reject")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> rejectProject(
            @PathVariable Long id,
            @RequestBody RejectProjectRequest request,
            Authentication authentication) {
        log.info("Admin {} rejecting project {}", authentication.getName(), id);
        
        Long adminId = currentUser(authentication).getId();
        projectValidationService.rejectProject(id, adminId, request);
        
        return ResponseEntity.ok(ApiResponse.success("Project rejected successfully", null));
    }
    
    /**
     * Assign mentor to project
     */
    @PostMapping("/projects/{id}/assign-mentor")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<Project>> assignMentor(
            @PathVariable Long id,
            @RequestBody AssignMentorRequest request) {
        log.info("Assigning mentor {} to project {}", request.getMentorId(), id);
        
        Project updated = projectValidationService.assignMentor(id, request.getMentorId(), request.getMessage());
        
        return ResponseEntity.ok(ApiResponse.success("Mentor assigned successfully", updated));
    }

    private User currentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmailAndDeletedAtIsNull(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
