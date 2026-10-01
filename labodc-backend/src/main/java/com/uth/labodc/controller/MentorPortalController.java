package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.mentor.MentorTaskUpsertRequest;
import com.uth.labodc.dto.mentor.MentorApplicationDTO;
import com.uth.labodc.dto.mentor.MentorApplicationDecisionRequest;
import com.uth.labodc.dto.mentor.MentorDashboardDTO;
import com.uth.labodc.dto.mentor.MentorInvitationDTO;
import com.uth.labodc.dto.mentor.MentorProjectOptionDTO;
import com.uth.labodc.dto.mentor.MentorReportDTO;
import com.uth.labodc.dto.mentor.MentorTaskDTO;
import com.uth.labodc.dto.mentor.MentorTaskSubmissionDTO;
import com.uth.labodc.dto.mentor.MentorTalentEvaluationDTO;
import com.uth.labodc.dto.mentor.MentorTalentOptionDTO;
import com.uth.labodc.dto.mentor.SubmitEvaluationRequest;
import com.uth.labodc.exception.ResourceNotFoundException;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.UserRepository;
import com.uth.labodc.service.MentorPortalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/mentor")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class MentorPortalController {

    private final MentorPortalService mentorPortalService;
    private final UserRepository userRepository;

    @GetMapping("/dashboard")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<MentorDashboardDTO>> dashboard(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getDashboard(user)));
    }

    @GetMapping("/invitations")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorInvitationDTO>>> invitations(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getInvitations(user)));
    }

    @GetMapping("/projects")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorProjectOptionDTO>>> projects(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getProjects(user)));
    }

    @PostMapping("/invitations/{id}/accept")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<String>> acceptInvitation(Authentication authentication, @PathVariable long id) {
        User user = currentUser(authentication);
        mentorPortalService.acceptInvitation(user, id);
        return ResponseEntity.ok(ApiResponse.success("Accepted", null));
    }

    @PostMapping("/invitations/{id}/reject")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<String>> rejectInvitation(
            Authentication authentication,
            @PathVariable long id,
            @RequestBody(required = false) Map<String, String> body
    ) {
        User user = currentUser(authentication);
        String reason = body != null ? body.get("reason") : null;
        mentorPortalService.rejectInvitation(user, id, reason);
        return ResponseEntity.ok(ApiResponse.success("Rejected", null));
    }

    @GetMapping("/tasks")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorTaskDTO>>> tasks(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getTasks(user)));
    }

    @GetMapping("/projects/{projectId}/tasks")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorTaskDTO>>> projectTasks(Authentication authentication, @PathVariable long projectId) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getProjectTasks(user, projectId)));
    }

    @GetMapping("/tasks/{taskId}/submissions")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorTaskSubmissionDTO>>> taskSubmissions(
            Authentication authentication,
            @PathVariable long taskId
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getTaskSubmissions(user, taskId)));
    }

    @GetMapping("/tasks/{taskId}/submissions/{submissionId}/file")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<Resource> downloadTaskSubmissionFile(
            Authentication authentication,
            @PathVariable long taskId,
            @PathVariable long submissionId
    ) {
        User user = currentUser(authentication);
        Resource resource = mentorPortalService.getTaskSubmissionFile(user, taskId, submissionId);

        String filename = "submission";
        try {
            if (resource.getFilename() != null) {
                filename = resource.getFilename();
            }
        } catch (Exception ignored) {
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(resource);
    }

    @GetMapping("/projects/{projectId}/applications")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorApplicationDTO>>> projectApplications(
            Authentication authentication,
            @PathVariable long projectId
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getProjectApplications(user, projectId)));
    }

    @PostMapping("/projects/{projectId}/applications/{memberId}/approve")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<String>> approveApplication(
            Authentication authentication,
            @PathVariable long projectId,
            @PathVariable long memberId
    ) {
        User user = currentUser(authentication);
        mentorPortalService.approveApplication(user, projectId, memberId);
        return ResponseEntity.ok(ApiResponse.success("Approved", null));
    }

    @PostMapping("/projects/{projectId}/applications/{memberId}/reject")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<String>> rejectApplication(
            Authentication authentication,
            @PathVariable long projectId,
            @PathVariable long memberId,
            @RequestBody(required = false) MentorApplicationDecisionRequest body
    ) {
        User user = currentUser(authentication);
        String reason = body != null ? body.getReason() : null;
        mentorPortalService.rejectApplication(user, projectId, memberId, reason);
        return ResponseEntity.ok(ApiResponse.success("Rejected", null));
    }

    @PostMapping("/projects/{projectId}/tasks")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<MentorTaskDTO>> createTask(
            Authentication authentication,
            @PathVariable long projectId,
            @RequestBody MentorTaskUpsertRequest request
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.createTask(user, projectId, request)));
    }

    @PostMapping("/projects/{projectId}/close-recruiting")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<String>> closeRecruiting(
            Authentication authentication,
            @PathVariable long projectId
    ) {
        User user = currentUser(authentication);
        mentorPortalService.closeRecruiting(user, projectId);
        return ResponseEntity.ok(ApiResponse.success("Closed recruiting", null));
    }

    @PostMapping("/projects/{projectId}/progress")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<Integer>> updateProjectProgress(
            Authentication authentication,
            @PathVariable long projectId,
            @RequestBody(required = false) Map<String, Integer> body
    ) {
        User user = currentUser(authentication);
        Integer progress = body != null ? body.get("progress") : null;
        int updated = mentorPortalService.updateProjectProgress(user, projectId, progress);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    @PutMapping("/projects/{projectId}/tasks/{taskId}")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<MentorTaskDTO>> updateTask(
            Authentication authentication,
            @PathVariable long projectId,
            @PathVariable long taskId,
            @RequestBody MentorTaskUpsertRequest request
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.updateTask(user, projectId, taskId, request)));
    }

    @DeleteMapping("/projects/{projectId}/tasks/{taskId}")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<String>> deleteTask(
            Authentication authentication,
            @PathVariable long projectId,
            @PathVariable long taskId
    ) {
        User user = currentUser(authentication);
        mentorPortalService.deleteTask(user, projectId, taskId);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    @GetMapping("/evaluations")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorTalentEvaluationDTO>>> evaluations(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getEvaluations(user, null)));
    }

    @GetMapping("/projects/{projectId}/evaluations")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorTalentEvaluationDTO>>> projectEvaluations(Authentication authentication, @PathVariable long projectId) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getEvaluations(user, projectId)));
    }

    @GetMapping("/projects/{projectId}/talents")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorTalentOptionDTO>>> projectTalents(Authentication authentication, @PathVariable long projectId) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getProjectTalents(user, projectId)));
    }

    @PostMapping("/projects/{projectId}/evaluations")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<MentorTalentEvaluationDTO>> submitEvaluation(
            Authentication authentication,
            @PathVariable long projectId,
            @RequestBody SubmitEvaluationRequest body
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.submitEvaluation(user, projectId, body)));
    }

    @GetMapping("/reports")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<List<MentorReportDTO>>> reports(Authentication authentication) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(mentorPortalService.getReports(user)));
    }

    @PostMapping(value = "/reports", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<ApiResponse<MentorReportDTO>> submitReport(
            Authentication authentication,
            @RequestParam("projectId") Long projectId,
            @RequestParam("student") String student,
            @RequestParam("studentId") String studentId,
            @RequestParam("reportName") String reportName,
            @RequestParam(value = "submittedDate", required = false) String submittedDate,
            @RequestParam("dueDate") String dueDate,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "summary", required = false) String summary,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        User user = currentUser(authentication);
        return ResponseEntity.ok(ApiResponse.success(
                mentorPortalService.submitReport(user, projectId, student, studentId, reportName, submittedDate, dueDate, status, summary, file)
        ));
    }

    @GetMapping("/reports/{id}/file")
    @PreAuthorize("hasRole('MENTOR')")
    public ResponseEntity<Resource> downloadReportFile(Authentication authentication, @PathVariable long id) {
        User user = currentUser(authentication);
        Resource resource = mentorPortalService.getReportFile(user, id);

        String filename = "report";
        try {
            if (resource.getFilename() != null) {
                filename = resource.getFilename();
            }
        } catch (Exception ignored) {
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(resource);
    }

    private User currentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmailAndDeletedAtIsNull(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
