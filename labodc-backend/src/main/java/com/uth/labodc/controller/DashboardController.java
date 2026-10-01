package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.dashboard.*;
import com.uth.labodc.service.DashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class DashboardController {
    
    private final DashboardService dashboardService;
    
    /**
     * Get dashboard statistics
     * Accessible by LAB_ADMIN and SYSTEM_ADMIN
     */
    @GetMapping("/stats")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<DashboardStatsDTO>> getDashboardStats() {
        log.info("GET /api/dashboard/stats - Fetching dashboard statistics");
        
        try {
            DashboardStatsDTO stats = dashboardService.getDashboardStats();
            return ResponseEntity.ok(ApiResponse.success(stats));
        } catch (Exception e) {
            log.error("Error fetching dashboard stats", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to fetch dashboard statistics: " + e.getMessage()));
        }
    }
    
    /**
     * Get recent activities
     * @param limit Number of activities to return (default: 10)
     */
    @GetMapping("/activities")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<RecentActivityDTO>>> getRecentActivities(
            @RequestParam(defaultValue = "10") int limit) {
        log.info("GET /api/dashboard/activities - Fetching recent activities, limit: {}", limit);
        
        try {
            List<RecentActivityDTO> activities = dashboardService.getRecentActivities(limit);
            return ResponseEntity.ok(ApiResponse.success(activities));
        } catch (Exception e) {
            log.error("Error fetching recent activities", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to fetch recent activities: " + e.getMessage()));
        }
    }
    
    /**
     * Get pending approvals
     * @param limit Number of pending items to return (default: 10)
     */
    @GetMapping("/approvals")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<PendingApprovalDTO>>> getPendingApprovals(
            @RequestParam(defaultValue = "10") int limit) {
        log.info("GET /api/dashboard/approvals - Fetching pending approvals, limit: {}", limit);
        
        try {
            List<PendingApprovalDTO> approvals = dashboardService.getPendingApprovals(limit);
            return ResponseEntity.ok(ApiResponse.success(approvals));
        } catch (Exception e) {
            log.error("Error fetching pending approvals", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to fetch pending approvals: " + e.getMessage()));
        }
    }
    
    /**
     * Get revenue chart data
     * @param months Number of months to include (default: 6)
     */
    @GetMapping("/revenue")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<RevenueChartDTO>>> getRevenueChart(
            @RequestParam(defaultValue = "6") int months) {
        log.info("GET /api/dashboard/revenue - Fetching revenue chart, months: {}", months);
        
        try {
            List<RevenueChartDTO> chartData = dashboardService.getRevenueChart(months);
            return ResponseEntity.ok(ApiResponse.success(chartData));
        } catch (Exception e) {
            log.error("Error fetching revenue chart", e);
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to fetch revenue chart: " + e.getMessage()));
        }
    }
}
