package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.enterprise.*;
import com.uth.labodc.dto.project.AssignMentorRequest;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.UserRepository;
import com.uth.labodc.service.EnterprisePortalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/enterprise")
@RequiredArgsConstructor
public class EnterprisePortalController {

    private final EnterprisePortalService enterprisePortalService;
    private final UserRepository userRepository;

    @GetMapping("/dashboard/summary")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterpriseDashboardSummaryDTO>> getDashboardSummary(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getDashboardSummary(user)));
    }

    @GetMapping("/dashboard/recent-projects")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterpriseRecentProjectDTO>>> getRecentProjects(
            Authentication authentication,
            @RequestParam(defaultValue = "5") int limit
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getRecentProjects(user, limit)));
    }

    @GetMapping("/projects/summary")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterpriseProjectSummaryDTO>> getProjectSummary(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getProjectSummary(user)));
    }

    @GetMapping("/projects")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterpriseProjectItemDTO>>> getProjects(
            Authentication authentication,
            @RequestParam(required = false) String status
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getProjects(user, status)));
    }

    @GetMapping("/mentors")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterpriseMentorOptionDTO>>> getMentors(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getMentors(user)));
    }

    @GetMapping("/proposals/summary")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterpriseProposalSummaryDTO>> getProposalSummary(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getProposalSummary(user)));
    }

    @GetMapping("/proposals")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterpriseProposalDTO>>> getProposals(
            Authentication authentication,
            @RequestParam(required = false) String status
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getProposals(user, status)));
    }

    @GetMapping("/payments/summary")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterprisePaymentSummaryDTO>> getPaymentSummary(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getPaymentSummary(user)));
    }

    @GetMapping("/payments")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterprisePaymentDTO>>> getPayments(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getPayments(user)));
    }

    @PostMapping("/payments")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterprisePaymentDTO>> createPayment(
            Authentication authentication,
            @RequestBody CreateEnterprisePaymentRequest request
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.createPayment(user, request)));
    }

    @PutMapping("/projects/{id}")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<String>> updateProject(
            Authentication authentication,
            @PathVariable long id,
            @RequestBody UpdateEnterpriseProjectRequest request
    ) {
        User user = currentUser(authentication);
        enterprisePortalService.updateProject(user, id, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật dự án thành công", null));
    }

    @PostMapping("/projects/{id}/assign-mentor")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<String>> assignMentor(
            Authentication authentication,
            @PathVariable long id,
            @RequestBody AssignMentorRequest request
    ) {
        User user = currentUser(authentication);
        enterprisePortalService.assignMentor(user, id, request.getMentorId(), request.getMessage());
        return ResponseEntity.ok(ApiResponse.success("Đã gửi lời mời mentor", null));
    }

    @PostMapping("/projects/{id}/start")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<String>> startProject(
            Authentication authentication,
            @PathVariable long id
    ) {
        User user = currentUser(authentication);
        enterprisePortalService.startProject(user, id);
        return ResponseEntity.ok(ApiResponse.success("Đã chuyển dự án sang trạng thái đang thực hiện", null));
    }

    @DeleteMapping("/projects/{id}")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<String>> deleteProject(
            Authentication authentication,
            @PathVariable long id
    ) {
        User user = currentUser(authentication);
        enterprisePortalService.deleteProject(user, id);
        return ResponseEntity.ok(ApiResponse.success("Xóa dự án thành công", null));
    }

    @GetMapping("/reports/summary")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterpriseReportSummaryDTO>> getReportSummary(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getReportSummary(user)));
    }

    @GetMapping("/reports/projects")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterpriseProjectReportDTO>>> getProjectReports(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getProjectReports(user)));
    }

    @GetMapping("/feedback")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<List<EnterpriseFeedbackDTO>>> getFeedbacks(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.getFeedbacks(user)));
    }

    @PostMapping("/feedback")
    @PreAuthorize("hasRole('ENTERPRISE')")
    public ResponseEntity<ApiResponse<EnterpriseFeedbackDTO>> createFeedback(
            Authentication authentication,
            @RequestBody CreateEnterpriseFeedbackRequest request
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(enterprisePortalService.createFeedback(user, request)));
    }

    private User currentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmailAndDeletedAtIsNull(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
