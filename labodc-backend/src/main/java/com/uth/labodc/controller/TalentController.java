package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.talent.*;
import com.uth.labodc.service.TalentService;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/talent")
@RequiredArgsConstructor
@Slf4j
public class TalentController {
    
    private final TalentService talentService;
    private final UserRepository userRepository;
    
    /**
     * GET /api/talent/profile
     * Lấy thông tin profile của talent hiện tại
     */
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<TalentProfileDTO>> getProfile(
            Authentication authentication) {
        User user = currentUser(authentication);
        TalentProfileDTO profile = talentService.getProfile(user.getId());
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    /**
     * GET /api/talent/dashboard
     * Lấy dữ liệu dashboard cho talent
     */
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<TalentDashboardDTO>> getDashboard(
            Authentication authentication) {
        User user = currentUser(authentication);
        TalentDashboardDTO dashboard = talentService.getDashboard(user.getId());
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }

    /**
     * GET /api/talent/projects/available
     * Danh sách dự án đang tuyển
     */
    @GetMapping("/projects/available")
    public ResponseEntity<ApiResponse<TalentProjectPageDTO>> getAvailableProjects(
            @PageableDefault(size = 20) Pageable pageable,
            @RequestParam(value = "technology", required = false) String technology,
            @RequestParam(value = "minBudget", required = false) BigDecimal minBudget,
            @RequestParam(value = "maxBudget", required = false) BigDecimal maxBudget,
            @RequestParam(value = "sort", required = false) String sort
    ) {
        TalentProjectPageDTO result = talentService.getAvailableProjects(pageable, technology, minBudget, maxBudget, sort);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * GET /api/talent/projects/{id}
     * Xem chi tiết dự án cho talent
     */
    @GetMapping("/projects/{id}")
    public ResponseEntity<ApiResponse<TalentProjectDTO>> getProjectDetail(
            @PathVariable Long id) {
        TalentProjectDTO detail = talentService.getProjectDetail(id);
        return ResponseEntity.ok(ApiResponse.success(detail));
    }
    
    /**
     * PUT /api/talent/profile
     * Cập nhật thông tin profile của talent
     */
    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<TalentProfileDTO>> updateProfile(
            Authentication authentication,
            @RequestBody @Valid TalentProfileDTO profileDTO) {
        User user = currentUser(authentication);
        TalentProfileDTO updated = talentService.updateProfile(user.getId(), profileDTO);
        return ResponseEntity.ok(ApiResponse.success("Profile updated successfully", updated));
    }
    
    /**
     * POST /api/talent/skills
     * Thêm skill mới cho talent
     */
    @PostMapping("/skills")
    public ResponseEntity<ApiResponse<TalentSkillDTO>> addSkill(
            Authentication authentication,
            @RequestBody @Valid TalentSkillDTO skillDTO) {
        User user = currentUser(authentication);
        try {
            TalentSkillDTO created = talentService.addSkill(user.getId(), skillDTO);
            return ResponseEntity.ok(ApiResponse.success("Skill added successfully", created));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
    
    /**
     * DELETE /api/talent/skills/{id}
     * Xóa skill của talent
     */
    @DeleteMapping("/skills/{id}")
    public ResponseEntity<ApiResponse<Void>> removeSkill(
            Authentication authentication,
            @PathVariable Long id) {
        User user = currentUser(authentication);
        try {
            talentService.removeSkill(user.getId(), id);
            return ResponseEntity.ok(ApiResponse.success("Skill removed successfully", (Void) null));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
    
    /**
     * POST /api/talent/certifications
     * Thêm certification mới cho talent
     */
    @PostMapping("/certifications")
    public ResponseEntity<ApiResponse<TalentCertificationDTO>> addCertification(
            Authentication authentication,
            @RequestBody @Valid TalentCertificationDTO certDTO) {
        User user = currentUser(authentication);
        TalentCertificationDTO created = talentService.addCertification(user.getId(), certDTO);
        return ResponseEntity.ok(ApiResponse.success("Certification added successfully", created));
    }

    /**
     * POST /api/talent/profile/avatar
     * Upload avatar cho talent
     */
    @PostMapping("/profile/avatar")
    public ResponseEntity<ApiResponse<String>> uploadAvatar(
            Authentication authentication,
            @RequestParam("file") MultipartFile file) {
        User user = currentUser(authentication);
        String url = talentService.storeAvatar(user.getId(), file);
        return ResponseEntity.ok(ApiResponse.success("Avatar uploaded successfully", url));
    }

    /**
     * POST /api/talent/profile/cv
     * Upload CV cho talent
     */
    @PostMapping("/profile/cv")
    public ResponseEntity<ApiResponse<String>> uploadCv(
            Authentication authentication,
            @RequestParam("file") MultipartFile file) {
        User user = currentUser(authentication);
        String url = talentService.storeCv(user.getId(), file);
        return ResponseEntity.ok(ApiResponse.success("CV uploaded successfully", url));
    }
    
    /**
     * POST /api/talent/projects/{id}/join
     * Đăng ký tham gia project
     */
    @PostMapping("/projects/{id}/join")
    public ResponseEntity<ApiResponse<String>> joinProject(
            Authentication authentication,
            @PathVariable Long id,
            @RequestBody @Valid JoinProjectRequest request) {
        User user = currentUser(authentication);
        ApiResponse<String> result = talentService.joinProject(user.getId(), id, request);
        return result.isSuccess() ? 
            ResponseEntity.ok(result) : 
            ResponseEntity.badRequest().body(result);
    }
    
    /**
     * GET /api/talent/projects/my-projects
     * Xem danh sách projects đã tham gia
     */
    @GetMapping("/projects/my-projects")
    public ResponseEntity<ApiResponse<List<TalentProjectDTO>>> getMyProjects(
            Authentication authentication) {
        User user = currentUser(authentication);
        List<TalentProjectDTO> projects = talentService.getMyProjects(user.getId());
        return ResponseEntity.ok(ApiResponse.success(projects));
    }

    /**
     * GET /api/talent/tasks
     * Xem danh sách task được giao cho talent (có thể lọc theo projectId)
     */
    @GetMapping("/tasks")
    public ResponseEntity<ApiResponse<List<TalentTaskDTO>>> getAssignedTasks(
            Authentication authentication,
            @RequestParam(value = "projectId", required = false) Long projectId) {
        User user = currentUser(authentication);
        List<TalentTaskDTO> tasks = talentService.getAssignedTasks(user.getId(), projectId);
        return ResponseEntity.ok(ApiResponse.success(tasks));
    }

    /**
     * POST /api/talent/tasks/{taskId}/submit
     * Talent ná»™p file bÃ¡o cÃ¡o cho nhiá»‡m vá»¥
     */
    @PostMapping(value = "/tasks/{taskId}/submit", consumes = "multipart/form-data")
    public ResponseEntity<ApiResponse<TalentTaskSubmissionDTO>> submitTaskReport(
            Authentication authentication,
            @PathVariable Long taskId,
            @RequestParam("file") MultipartFile file) {
        User user = currentUser(authentication);
        TalentTaskSubmissionDTO result = talentService.submitTaskReport(user.getId(), taskId, file);
        return ResponseEntity.ok(ApiResponse.success("Submitted", result));
    }

    private User currentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmailAndDeletedAtIsNull(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
