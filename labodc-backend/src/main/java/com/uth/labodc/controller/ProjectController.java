package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.project.CreateProjectRequest;
import com.uth.labodc.dto.project.ProjectListDTO;
import com.uth.labodc.dto.project.ProjectMemberResponse;
import com.uth.labodc.dto.project.ProjectResponse;
import com.uth.labodc.dto.project.ProjectStatsDTO;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.UserRepository;
import com.uth.labodc.service.ProjectDataService;
import com.uth.labodc.service.ProjectManagementService;
import com.uth.labodc.service.ProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
public class ProjectController {

    private final ProjectDataService projectDataService;
    private final ProjectManagementService projectManagementService;
    private final UserRepository userRepository;
    private final ProjectService projectService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProjectResponse>>> getProjects(
            @RequestParam(value = "status", required = false) String status
    ) {
        return ResponseEntity.ok(ApiResponse.success(projectDataService.getProjects(status)));
    }
    
    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<ProjectStatsDTO>> getProjectStats() {
        log.info("Fetching project statistics");
        ProjectStatsDTO stats = projectManagementService.getProjectStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProjectResponse>> getProjectById(@PathVariable Long id) {
        log.info("Fetching project details for id: {}", id);
        ProjectResponse project = projectDataService.getProjectById(id);
        return ResponseEntity.ok(ApiResponse.success(project));
    }
    
    @GetMapping("/management")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<ProjectListDTO>>> getProjectsForManagement(
            @RequestParam(value = "validated", required = false) String validated,
            @RequestParam(value = "search", required = false) String search) {
        log.info("Fetching projects for management, validated: {}, search: {}", validated, search);
        
        List<ProjectListDTO> projects = projectManagementService.getAllProjectsWithStats(validated, search);
        return ResponseEntity.ok(ApiResponse.success(projects));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ProjectResponse>> createProject(
            Authentication authentication,
            @RequestBody CreateProjectRequest request
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(projectDataService.createProject(user, request)));
    }

    @GetMapping("/enterprise/{enterpriseId}")
    public ResponseEntity<ApiResponse<List<ProjectResponse>>> getEnterpriseProjects(
            @PathVariable long enterpriseId
    ) {
        return ResponseEntity.ok(ApiResponse.success(projectDataService.getProjectsByEnterprise(enterpriseId)));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<ProjectResponse>>> getMyProjects(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(projectDataService.getProjectsForUser(user)));
    }

    @GetMapping("/{projectId}/members")
    public ResponseEntity<ApiResponse<List<ProjectMemberResponse>>> getProjectMembers(
            @PathVariable long projectId
    ) {
        return ResponseEntity.ok(ApiResponse.success(projectDataService.getProjectMembers(projectId)));
    }

    @PostMapping("/{projectId}/join")
    public ResponseEntity<ApiResponse<String>> joinProject(
            @PathVariable long projectId,
            Authentication authentication,
            @RequestBody(required = false) Map<String, String> payload
    ) {
        User user = currentUser(authentication);
        String motivation = null;
        if (payload != null) {
            motivation = payload.getOrDefault("motivationLetter", payload.get("message"));
        }
        projectDataService.joinProject(projectId, user, motivation);
        return ResponseEntity.ok(ApiResponse.success("Tham gia dự án thành công", null));
    }

    @PostMapping("/{projectId}/leave")
    public ResponseEntity<ApiResponse<String>> leaveProject(
            @PathVariable long projectId,
            Authentication authentication
    ) {
        User user = currentUser(authentication);
        projectDataService.leaveProject(projectId, user);
        return ResponseEntity.ok(ApiResponse.success("Đã rời dự án", null));
    }

    @PutMapping("/{id}/approve")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> approveProject(
            @PathVariable Long id,
            Authentication authentication) {
        log.info("Admin {} approving project {}", authentication.getName(), id);
        
        // Get admin user ID from authentication
        Long adminId = currentUser(authentication).getId();
        
        projectService.validateProject(id, adminId);
        return ResponseEntity.ok(ApiResponse.success("Đã phê duyệt dự án", null));
    }
    
    @PutMapping("/{id}/reject")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> rejectProject(
            @PathVariable Long id,
            @RequestBody Map<String, String> body,
            Authentication authentication) {
        log.info("Admin {} rejecting project {}", authentication.getName(), id);
        
        // Get admin user ID from authentication
        Long adminId = currentUser(authentication).getId();
        
        String reason = body != null ? body.get("reason") : null;
        if (reason == null || reason.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(
                ApiResponse.error("Lý do từ chối không được để trống")
            );
        }
        
        log.info("Rejection reason: {}", reason);
        projectService.rejectProject(id, adminId, reason);
        return ResponseEntity.ok(ApiResponse.success("Đã từ chối dự án", null));
    }
    
    @PutMapping("/{id}/validate")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> validateProject(
            @PathVariable Long id,
            Authentication authentication) {
        // Deprecated - use /approve endpoint instead
        return approveProject(id, authentication);
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> deleteProject(
            @PathVariable Long id,
            Authentication authentication) {
        log.info("Admin {} deleting project {}", authentication.getName(), id);
        
        // Get admin user ID from authentication
        Long adminId = currentUser(authentication).getId();
        
        // For now, reject with generic reason
        projectService.rejectProject(id, adminId, "Deleted by admin");
        return ResponseEntity.ok(ApiResponse.success("Đã xóa dự án", null));
    }

    private User currentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmailAndDeletedAtIsNull(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
