package com.uth.labodc.controller;

import com.uth.labodc.dto.ApiResponse;
import com.uth.labodc.dto.report.*;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.UserRepository;
import com.uth.labodc.service.ExcelExportService;
import com.uth.labodc.service.TransparencyReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/lab-admin/transparency-reports")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TransparencyReportController {
    
    private final TransparencyReportService transparencyReportService;
    private final ExcelExportService excelExportService;
    private final UserRepository userRepository;
    
    /**
     * Get all transparency reports
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<List<TransparencyReportDTO>>> getReports(
            @RequestParam(required = false) String status) {
        log.info("Fetching transparency reports, status filter: {}", status);
        List<TransparencyReportDTO> reports = transparencyReportService.getReports(status);
        return ResponseEntity.ok(ApiResponse.success(reports));
    }
    
    /**
     * Get report by ID
     */
    @GetMapping("/{reportId}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<TransparencyReportDTO>> getReportById(
            @PathVariable Long reportId) {
        log.info("Fetching transparency report: {}", reportId);
        TransparencyReportDTO report = transparencyReportService.getReportById(reportId);
        return ResponseEntity.ok(ApiResponse.success(report));
    }
    
    /**
     * Create new report
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<TransparencyReportDTO>> createReport(
            @RequestBody CreateReportRequest request,
            Authentication authentication) {
        log.info("Creating transparency report for period: {}", request.getPeriod());
        
        Long adminId = currentUser(authentication).getId();
        TransparencyReportDTO report = transparencyReportService.createReport(request, adminId);
        
        return ResponseEntity.ok(ApiResponse.success("Report created successfully", report));
    }
    
    /**
     * Publish report
     */
    @PostMapping("/{reportId}/publish")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<TransparencyReportDTO>> publishReport(
            @PathVariable Long reportId,
            @RequestBody PublishReportRequest request) {
        log.info("Publishing transparency report: {}", reportId);
        
        TransparencyReportDTO report = transparencyReportService.publishReport(reportId, request);
        
        return ResponseEntity.ok(ApiResponse.success("Report published successfully", report));
    }
    
    /**
     * Delete report
     */
    @DeleteMapping("/{reportId}")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<String>> deleteReport(@PathVariable Long reportId) {
        log.info("Deleting transparency report: {}", reportId);
        transparencyReportService.deleteReport(reportId);
        return ResponseEntity.ok(ApiResponse.success("Report deleted successfully", null));
    }
    
    /**
     * Export report to Excel
     */
    @GetMapping("/{reportId}/export/excel")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<byte[]> exportReportToExcel(@PathVariable Long reportId) {
        log.info("Exporting transparency report {} to Excel", reportId);
        
        try {
            byte[] excelData = excelExportService.exportTransparencyReportToExcel(reportId);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment", "bao-cao-minh-bach-" + reportId + ".xlsx");
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(excelData);
                    
        } catch (IOException e) {
            log.error("Error exporting report to Excel", e);
            throw new RuntimeException("Failed to export report to Excel: " + e.getMessage());
        }
    }
    
    /**
     * Archive report and upload to Cloudinary
     */
    @PostMapping("/{reportId}/archive")
    @PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
    public ResponseEntity<ApiResponse<TransparencyReportDTO>> archiveReport(@PathVariable Long reportId) {
        log.info("Archiving transparency report: {}", reportId);
        
        try {
            TransparencyReportDTO report = transparencyReportService.archiveReport(reportId);
            return ResponseEntity.ok(ApiResponse.success("Report archived successfully", report));
        } catch (Exception e) {
            log.error("Error archiving report", e);
            throw new RuntimeException("Failed to archive report: " + e.getMessage());
        }
    }
    
    /**
     * Download PDF report
     */
    @GetMapping("/{reportId}/download")
    @org.springframework.web.bind.annotation.CrossOrigin(origins = "*")
    public ResponseEntity<org.springframework.core.io.Resource> downloadPDF(@PathVariable Long reportId) {
        log.info("Downloading PDF for report: {}", reportId);
        
        try {
            byte[] pdfBytes = transparencyReportService.downloadPDF(reportId);
            TransparencyReportDTO report = transparencyReportService.getReportById(reportId);
            
            String filename = String.format("report_%d_%s.pdf", reportId, report.getPeriod());
            
            org.springframework.core.io.ByteArrayResource resource = 
                new org.springframework.core.io.ByteArrayResource(pdfBytes);
            
            return ResponseEntity.ok()
                .header(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, 
                    "attachment; filename=\"" + filename + "\"")
                .contentType(org.springframework.http.MediaType.APPLICATION_PDF)
                .contentLength(pdfBytes.length)
                .body(resource);
        } catch (Exception e) {
            log.error("Error downloading PDF", e);
            throw new RuntimeException("Failed to download PDF: " + e.getMessage());
        }
    }

    private User currentUser(Authentication authentication) {
        String email = authentication.getName();
        return userRepository.findByEmailAndDeletedAtIsNull(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
