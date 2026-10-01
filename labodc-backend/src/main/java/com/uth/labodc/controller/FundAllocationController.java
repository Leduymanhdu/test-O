package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.fund.*;
import com.uth.labodc.service.FundAllocationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lab-admin/fund-allocation")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class FundAllocationController {
    
    private final FundAllocationService fundAllocationService;
    
    /**
     * Get fund allocation statistics
     */
    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<FundAllocationStatsDTO>> getFundAllocationStats() {
        log.info("Fetching fund allocation statistics");
        FundAllocationStatsDTO stats = fundAllocationService.getFundAllocationStats();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
    
    /**
     * Get all fund allocations
     */
    @GetMapping("/allocations")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<FundAllocationDTO>>> getAllFundAllocations(
            @RequestParam(required = false) String status) {
        log.info("Fetching fund allocations, status filter: {}", status);
        List<FundAllocationDTO> allocations = fundAllocationService.getAllFundAllocations(status);
        return ResponseEntity.ok(ApiResponse.success(allocations));
    }
    
    /**
     * Get fund allocation for a specific project
     */
    @GetMapping("/allocations/{projectId}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<FundAllocationDTO>> getFundAllocationByProjectId(
            @PathVariable Long projectId) {
        log.info("Fetching fund allocation for project: {}", projectId);
        FundAllocationDTO allocation = fundAllocationService.getFundAllocationByProjectId(projectId);
        return ResponseEntity.ok(ApiResponse.success(allocation));
    }
    
    /**
     * Disburse funds to mentor
     */
    @PostMapping("/allocations/{projectId}/disburse-mentor")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> disburseMentorFunds(
            @PathVariable Long projectId,
            @RequestBody DisburseMentorRequest request) {
        log.info("Disbursing mentor funds for project: {}", projectId);
        fundAllocationService.disburseMentorFunds(projectId, request);
        return ResponseEntity.ok(ApiResponse.success("Mentor funds disbursed successfully", null));
    }
    
    /**
     * Disburse funds to team
     */
    @PostMapping("/allocations/{projectId}/disburse-team")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> disburseTeamFunds(
            @PathVariable Long projectId,
            @RequestBody DisburseTeamRequest request) {
        log.info("Disbursing team funds for project: {}", projectId);
        fundAllocationService.disburseTeamFunds(projectId, request);
        return ResponseEntity.ok(ApiResponse.success("Team funds disbursed successfully", null));
    }
    
    /**
     * Update fund allocation
     */
    @PutMapping("/allocations/{projectId}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<FundAllocationDTO>> updateFundAllocation(
            @PathVariable Long projectId,
            @RequestBody FundAllocationDTO dto) {
        log.info("Updating fund allocation for project: {}", projectId);
        FundAllocationDTO updated = fundAllocationService.updateFundAllocation(projectId, dto);
        return ResponseEntity.ok(ApiResponse.success("Fund allocation updated successfully", updated));
    }
    
    /**
     * Delete fund allocation
     */
    @DeleteMapping("/allocations/{projectId}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> deleteFundAllocation(@PathVariable Long projectId) {
        log.info("Deleting fund allocation for project: {}", projectId);
        fundAllocationService.deleteFundAllocation(projectId);
        return ResponseEntity.ok(ApiResponse.success("Fund allocation deleted successfully", null));
    }
}
