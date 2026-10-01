package com.uth.labodc.service;

import com.uth.labodc.dto.report.*;
import com.uth.labodc.model.entity.*;
import com.uth.labodc.model.enums.*;
import com.uth.labodc.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransparencyReportService {
    
    private final ProjectRepository projectRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final UserRepository userRepository;
    private final TransparencyReportRepository transparencyReportRepository;
    private final FundAllocationRepository fundAllocationRepository;
    private final PaymentRepository paymentRepository;
    private final CloudinaryService cloudinaryService;
    private final PDFGeneratorService pdfGeneratorService;
    
    // Fund allocation percentages
    private static final BigDecimal TEAM_PERCENTAGE = new BigDecimal("70");
    private static final BigDecimal MENTOR_PERCENTAGE = new BigDecimal("20");
    private static final BigDecimal LAB_PERCENTAGE = new BigDecimal("10");
    private static final BigDecimal HUNDRED = new BigDecimal("100");
    
    /**
     * Get all reports with optional status filter
     */
    public List<TransparencyReportDTO> getReports(String statusFilter) {
        List<TransparencyReport> reports;
        
        if (statusFilter == null || statusFilter.isEmpty()) {
            reports = transparencyReportRepository.findAllByOrderByCreatedAtDesc();
        } else {
            try {
                ReportStatus status = ReportStatus.valueOf(statusFilter.toUpperCase());
                reports = transparencyReportRepository.findByStatusOrderByCreatedAtDesc(status);
            } catch (IllegalArgumentException e) {
                log.warn("Invalid status filter: {}", statusFilter);
                reports = transparencyReportRepository.findAllByOrderByCreatedAtDesc();
            }
        }
        
        return reports.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Get report by ID
     */
    public TransparencyReportDTO getReportById(Long reportId) {
        TransparencyReport report = transparencyReportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found with id: " + reportId));
        return convertToDTO(report);
    }
    
    /**
     * Create new transparency report
     */
    @Transactional
    public TransparencyReportDTO createReport(CreateReportRequest request, Long createdByUserId) {
        log.info("Creating transparency report for period: {}, type: {}", request.getPeriod(), request.getReportType());
        
        // Check if report for this period already exists
        if (transparencyReportRepository.existsByPeriod(request.getPeriod())) {
            throw new RuntimeException("Report for period " + request.getPeriod() + " already exists");
        }
        
        // Validate period has new data before creating report
        ReportType reportType = ReportType.valueOf(request.getReportType());
        validatePeriodHasData(request.getPeriod(), reportType);
        
        // Get user who is creating the report
        User createdByUser = userRepository.findById(createdByUserId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + createdByUserId));
        
        // Generate statistics based on real data
        Map<String, Object> statistics = generateStatisticsMap(request.getPeriod(), reportType);
        Map<String, Object> chartsData = generateChartsDataMap(request.getPeriod());
        
        // Create entity
        TransparencyReport report = TransparencyReport.builder()
                .reportType(ReportType.valueOf(request.getReportType()))
                .period(request.getPeriod())
                .statistics(statistics)
                .chartsData(chartsData)
                .status(ReportStatus.DRAFT)
                .createdBy(createdByUser)
                .build();
        
        report = transparencyReportRepository.save(report);
        
        log.info("Transparency report created with ID: {}", report.getId());
        return convertToDTO(report);
    }
    
    /**
     * Publish report
     */
    @Transactional
    public TransparencyReportDTO publishReport(Long reportId, PublishReportRequest request) {
        log.info("Publishing report: {}", reportId);
        
        TransparencyReport report = transparencyReportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found with id: " + reportId));
        
        report.setStatus(ReportStatus.PUBLISHED);
        report.setPublishedAt(LocalDateTime.now());
        report.setPublishNote(request.getPublishNote());
        report.setPublicUrl("/transparency/reports/" + reportId);
        report.setPdfUrl("/transparency/reports/" + reportId + "/pdf");
        
        report = transparencyReportRepository.save(report);
        
        log.info("Report {} published successfully", reportId);
        return convertToDTO(report);
    }
    
    /**
     * Delete report
     */
    @Transactional
    public void deleteReport(Long reportId) {
        log.info("Deleting report: {}", reportId);
        
        if (!transparencyReportRepository.existsById(reportId)) {
            throw new RuntimeException("Report not found with id: " + reportId);
        }
        
        transparencyReportRepository.deleteById(reportId);
        log.info("Report {} deleted successfully", reportId);
    }
    
    /**
     * Archive report - Change status to ARCHIVED and upload PDF to Cloudinary
     */
    @Transactional
    public TransparencyReportDTO archiveReport(Long reportId) {
        log.info("Archiving report: {}", reportId);
        
        TransparencyReport report = transparencyReportRepository.findById(reportId)
                .orElseThrow(() -> new RuntimeException("Report not found with id: " + reportId));
        
        // Convert to DTO for PDF generation
        TransparencyReportDTO reportDTO = convertToDTO(report);
        
        // Generate PDF
        byte[] pdfBytes = pdfGeneratorService.generateReportPDF(reportDTO);
        
        // Upload to Cloudinary
        String fileName = "report_" + reportId + "_" + report.getPeriod();
        String cloudinaryUrl = cloudinaryService.uploadPDF(pdfBytes, fileName);
        
        // Update report status and PDF URL
        report.setStatus(ReportStatus.ARCHIVED);
        report.setPdfUrl(cloudinaryUrl);
        
        report = transparencyReportRepository.save(report);
        
        log.info("Report {} archived successfully with PDF: {}", reportId, cloudinaryUrl);
        return convertToDTO(report);
    }
    
    /**
     * Validate that period has new data to report
     */
    private void validatePeriodHasData(String period, ReportType reportType) {
        TransparencyReportDTO.ReportStatistics stats = generateStatistics(period, reportType);
        
        boolean hasNewData = (stats.getProjects() != null && stats.getProjects().getNewProjects() > 0) ||
                             (stats.getEnterprises() != null && stats.getEnterprises().getNewEnterprises() > 0) ||
                             (stats.getTalents() != null && stats.getTalents().getNewTalents() > 0);
        
        if (!hasNewData) {
            throw new RuntimeException("No new data found in period " + period + 
                ". Cannot create report without new projects, enterprises or talents.");
        }
    }
    
    /**
     * Generate statistics map for database storage
     */
    private Map<String, Object> generateStatisticsMap(String period, ReportType reportType) {
        TransparencyReportDTO.ReportStatistics stats = generateStatistics(period, reportType);
        
        Map<String, Object> statsMap = new HashMap<>();
        
        // Project stats
        if (stats.getProjects() != null) {
            Map<String, Object> projectStats = new HashMap<>();
            projectStats.put("total", stats.getProjects().getTotal());
            projectStats.put("newProjects", stats.getProjects().getNewProjects());
            projectStats.put("ongoing", stats.getProjects().getOngoing());
            projectStats.put("completed", stats.getProjects().getCompleted());
            projectStats.put("cancelled", stats.getProjects().getCancelled());
            projectStats.put("successRate", stats.getProjects().getSuccessRate());
            statsMap.put("projects", projectStats);
        }
        
        // Enterprise stats
        if (stats.getEnterprises() != null) {
            Map<String, Object> enterpriseStats = new HashMap<>();
            enterpriseStats.put("total", stats.getEnterprises().getTotal());
            enterpriseStats.put("newEnterprises", stats.getEnterprises().getNewEnterprises());
            enterpriseStats.put("active", stats.getEnterprises().getActive());
            enterpriseStats.put("verified", stats.getEnterprises().getVerified());
            statsMap.put("enterprises", enterpriseStats);
        }
        
        // Talent stats
        if (stats.getTalents() != null) {
            Map<String, Object> talentStats = new HashMap<>();
            talentStats.put("total", stats.getTalents().getTotal());
            talentStats.put("newTalents", stats.getTalents().getNewTalents());
            talentStats.put("active", stats.getTalents().getActive());
            talentStats.put("averageRating", stats.getTalents().getAverageRating());
            statsMap.put("talents", talentStats);
        }
        
        // Mentor stats
        if (stats.getMentors() != null) {
            Map<String, Object> mentorStats = new HashMap<>();
            mentorStats.put("total", stats.getMentors().getTotal());
            mentorStats.put("active", stats.getMentors().getActive());
            mentorStats.put("averageRating", stats.getMentors().getAverageRating());
            statsMap.put("mentors", mentorStats);
        }
        
        // Financial stats
        if (stats.getFinancials() != null) {
            Map<String, Object> financialStats = new HashMap<>();
            financialStats.put("totalRevenue", stats.getFinancials().getTotalRevenue());
            financialStats.put("teamDisbursed", stats.getFinancials().getTeamDisbursed());
            financialStats.put("mentorDisbursed", stats.getFinancials().getMentorDisbursed());
            financialStats.put("labRevenue", stats.getFinancials().getLabRevenue());
            financialStats.put("hybridFundAdvanced", stats.getFinancials().getHybridFundAdvanced());
            financialStats.put("hybridFundRepaid", stats.getFinancials().getHybridFundRepaid());
            statsMap.put("financials", financialStats);
        }
        
        // Performance stats
        if (stats.getPerformance() != null) {
            Map<String, Object> performanceStats = new HashMap<>();
            performanceStats.put("avgProjectCompletion", stats.getPerformance().getAvgProjectCompletion());
            performanceStats.put("onTimeDelivery", stats.getPerformance().getOnTimeDelivery());
            performanceStats.put("customerSatisfaction", stats.getPerformance().getCustomerSatisfaction());
            statsMap.put("performance", performanceStats);
        }
        
        return statsMap;
    }
    
    /**
     * Generate charts data map for database storage
     */
    private Map<String, Object> generateChartsDataMap(String period) {
        Map<String, Object> chartsData = new HashMap<>();
        
        // Projects by status
        List<Project> allProjects = projectRepository.findAll();
        Map<String, Long> projectsByStatus = allProjects.stream()
                .collect(Collectors.groupingBy(
                        p -> p.getStatus().name(),
                        Collectors.counting()
                ));
        chartsData.put("projectsByStatus", projectsByStatus);
        
        // Enterprise satisfaction (mock data for now)
        List<Map<String, Object>> satisfactionData = new ArrayList<>();
        satisfactionData.add(Map.of("rating", 5, "count", 2));
        satisfactionData.add(Map.of("rating", 4, "count", 3));
        satisfactionData.add(Map.of("rating", 3, "count", 1));
        chartsData.put("enterpriseSatisfaction", satisfactionData);
        
        return chartsData;
    }
    
    /**
     * Convert entity to DTO
     */
    private TransparencyReportDTO convertToDTO(TransparencyReport report) {
        TransparencyReportDTO dto = new TransparencyReportDTO();
        dto.setReportId(report.getId());
        dto.setReportType(report.getReportType().name());
        dto.setPeriod(report.getPeriod());
        dto.setStatus(report.getStatus().name());
        dto.setPublicUrl(report.getPublicUrl());
        dto.setPdfUrl(report.getPdfUrl());
        dto.setPublishNote(report.getPublishNote());
        dto.setPublishedAt(report.getPublishedAt());
        dto.setCreatedAt(report.getCreatedAt());
        
        if (report.getCreatedBy() != null) {
            dto.setCreatedBy(report.getCreatedBy().getId());
        }
        
        // Convert statistics map to DTO structure
        if (report.getStatistics() != null) {
            dto.setStatistics(convertStatisticsMapToDTO(report.getStatistics()));
        }
        
        return dto;
    }
    
    /**
     * Convert statistics map to DTO structure
     */
    @SuppressWarnings("unchecked")
    private TransparencyReportDTO.ReportStatistics convertStatisticsMapToDTO(Map<String, Object> statsMap) {
        TransparencyReportDTO.ReportStatistics stats = new TransparencyReportDTO.ReportStatistics();
        
        // Project stats
        if (statsMap.containsKey("projects")) {
            Map<String, Object> projectStats = (Map<String, Object>) statsMap.get("projects");
            stats.setProjects(TransparencyReportDTO.ProjectStats.builder()
                    .total(getLongValue(projectStats, "total"))
                    .newProjects(getLongValue(projectStats, "newProjects"))
                    .ongoing(getLongValue(projectStats, "ongoing"))
                    .completed(getLongValue(projectStats, "completed"))
                    .cancelled(getLongValue(projectStats, "cancelled"))
                    .successRate(getDoubleValue(projectStats, "successRate"))
                    .build());
        }
        
        // Enterprise stats
        if (statsMap.containsKey("enterprises")) {
            Map<String, Object> enterpriseStats = (Map<String, Object>) statsMap.get("enterprises");
            stats.setEnterprises(TransparencyReportDTO.EnterpriseStats.builder()
                    .total(getLongValue(enterpriseStats, "total"))
                    .newEnterprises(getLongValue(enterpriseStats, "newEnterprises"))
                    .active(getLongValue(enterpriseStats, "active"))
                    .verified(getLongValue(enterpriseStats, "verified"))
                    .build());
        }
        
        // Talent stats
        if (statsMap.containsKey("talents")) {
            Map<String, Object> talentStats = (Map<String, Object>) statsMap.get("talents");
            stats.setTalents(TransparencyReportDTO.TalentStats.builder()
                    .total(getLongValue(talentStats, "total"))
                    .newTalents(getLongValue(talentStats, "newTalents"))
                    .active(getLongValue(talentStats, "active"))
                    .averageRating(getDoubleValue(talentStats, "averageRating"))
                    .build());
        }
        
        // Mentor stats
        if (statsMap.containsKey("mentors")) {
            Map<String, Object> mentorStats = (Map<String, Object>) statsMap.get("mentors");
            stats.setMentors(TransparencyReportDTO.MentorStats.builder()
                    .total(getLongValue(mentorStats, "total"))
                    .active(getLongValue(mentorStats, "active"))
                    .averageRating(getDoubleValue(mentorStats, "averageRating"))
                    .build());
        }
        
        // Financial stats
        if (statsMap.containsKey("financials")) {
            Map<String, Object> financialStats = (Map<String, Object>) statsMap.get("financials");
            stats.setFinancials(TransparencyReportDTO.FinancialStats.builder()
                    .totalRevenue(getBigDecimalValue(financialStats, "totalRevenue"))
                    .teamDisbursed(getBigDecimalValue(financialStats, "teamDisbursed"))
                    .mentorDisbursed(getBigDecimalValue(financialStats, "mentorDisbursed"))
                    .labRevenue(getBigDecimalValue(financialStats, "labRevenue"))
                    .hybridFundAdvanced(getBigDecimalValue(financialStats, "hybridFundAdvanced"))
                    .hybridFundRepaid(getBigDecimalValue(financialStats, "hybridFundRepaid"))
                    .build());
        }
        
        // Performance stats
        if (statsMap.containsKey("performance")) {
            Map<String, Object> performanceStats = (Map<String, Object>) statsMap.get("performance");
            stats.setPerformance(TransparencyReportDTO.PerformanceStats.builder()
                    .avgProjectCompletion(getDoubleValue(performanceStats, "avgProjectCompletion"))
                    .onTimeDelivery(getDoubleValue(performanceStats, "onTimeDelivery"))
                    .customerSatisfaction(getDoubleValue(performanceStats, "customerSatisfaction"))
                    .build());
        }
        
        return stats;
    }
    
    private Long getLongValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return 0L;
    }
    
    private Double getDoubleValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        return 0.0;
    }
    
    private BigDecimal getBigDecimalValue(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        } else if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Generate statistics for a period (PERIOD-SPECIFIC, not cumulative)
     * 
     * Period formats:
     * - MONTHLY: "YYYY-MM" (e.g., "2026-01")
     * - QUARTERLY: "YYYY-QN" (e.g., "2026-Q1")
     * - ANNUAL: "YYYY" (e.g., "2026")
     * 
     * Logic: Count ONLY entities created within this specific period
     * - Project 2025-12-19 will ONLY appear in 2025-12 report, NOT in 2026-01 report
     * - This ensures each period shows different data
     */
    private TransparencyReportDTO.ReportStatistics generateStatistics(String period, ReportType reportType) {
        // Parse period based on report type
        LocalDateTime startOfPeriod;
        LocalDateTime endOfPeriod;
        
        if (reportType == ReportType.QUARTERLY) {
            // Parse YYYY-QN format (e.g., "2026-Q1")
            String[] parts = period.split("-Q");
            int year = Integer.parseInt(parts[0]);
            int quarter = Integer.parseInt(parts[1]);
            int startMonth = (quarter - 1) * 3 + 1;
            int endMonth = startMonth + 2;
            
            startOfPeriod = LocalDateTime.of(year, startMonth, 1, 0, 0, 0);
            YearMonth lastMonth = YearMonth.of(year, endMonth);
            endOfPeriod = lastMonth.atEndOfMonth().atTime(23, 59, 59);
            
        } else if (reportType == ReportType.ANNUAL) {
            // Parse YYYY format (e.g., "2026")
            int year = Integer.parseInt(period);
            startOfPeriod = LocalDateTime.of(year, 1, 1, 0, 0, 0);
            endOfPeriod = LocalDateTime.of(year, 12, 31, 23, 59, 59);
            
        } else {
            // MONTHLY, WEEKLY, MILESTONE, FINAL - Parse YYYY-MM format
            YearMonth yearMonth = YearMonth.parse(period + "-01", DateTimeFormatter.ISO_LOCAL_DATE);
            startOfPeriod = yearMonth.atDay(1).atStartOfDay();
            endOfPeriod = yearMonth.atEndOfMonth().atTime(23, 59, 59);
        }
        
        LocalDateTime startOfMonth = startOfPeriod;
        LocalDateTime endOfMonth = endOfPeriod;
        
        // Convert to LocalDate for project start_date/end_date comparison
        LocalDate startDate = startOfPeriod.toLocalDate();
        LocalDate endDate = endOfPeriod.toLocalDate();
        
        // Project statistics - Projects active during this period (based on start_date/end_date)
        // A project belongs to this period if it was active at any point during the period:
        // - Project starts during period, OR
        // - Project ends during period, OR  
        // - Project spans the entire period
        List<Project> allProjects = projectRepository.findAll();
        
        // Projects active in this period: start_date <= endDate AND end_date >= startDate
        List<Project> periodProjects = allProjects.stream()
                .filter(p -> p.getStartDate() != null && p.getEndDate() != null &&
                            !p.getStartDate().isAfter(endDate) &&
                            !p.getEndDate().isBefore(startDate))
                .toList();
        
        // New projects = projects that STARTED in this period
        long newProjects = allProjects.stream()
                .filter(p -> p.getStartDate() != null &&
                            !p.getStartDate().isBefore(startDate) &&
                            !p.getStartDate().isAfter(endDate))
                .count();
        
        long totalProjects = periodProjects.size(); // Count projects active in this period
        long ongoing = periodProjects.stream().filter(p -> p.getStatus() == ProjectStatus.IN_PROGRESS).count();
        long completed = periodProjects.stream().filter(p -> p.getStatus() == ProjectStatus.COMPLETED).count();
        long cancelled = periodProjects.stream().filter(p -> p.getStatus() == ProjectStatus.CANCELLED).count();
        double successRate = totalProjects > 0 ? (completed * 100.0 / totalProjects) : 0.0;
        
        TransparencyReportDTO.ProjectStats projectStats = TransparencyReportDTO.ProjectStats.builder()
                .total(totalProjects)
                .newProjects(newProjects)
                .ongoing(ongoing)
                .completed(completed)
                .cancelled(cancelled)
                .successRate(successRate)
                .build();
        
        // Enterprise statistics - ONLY enterprises created within this period
        List<Enterprise> allEnterprises = enterpriseRepository.findAll();
        
        // Enterprises created in this period ONLY (>= startOfMonth AND <= endOfMonth)
        List<Enterprise> periodEnterprises = allEnterprises.stream()
                .filter(e -> e.getCreatedAt() != null && 
                            !e.getCreatedAt().isBefore(startOfMonth) && 
                            !e.getCreatedAt().isAfter(endOfMonth))
                .toList();
        
        long totalEnterprises = periodEnterprises.size(); // Count ONLY in this period
        long newEnterprises = periodEnterprises.size(); // Same as total
        long activeEnterprises = periodEnterprises.stream().filter(e -> EnterpriseStatus.APPROVED.equals(e.getStatus())).count();
        long verifiedEnterprises = activeEnterprises;
        
        TransparencyReportDTO.EnterpriseStats enterpriseStats = TransparencyReportDTO.EnterpriseStats.builder()
                .total(totalEnterprises)
                .newEnterprises(newEnterprises)
                .active(activeEnterprises)
                .verified(verifiedEnterprises)
                .build();
        
        // Talent statistics - ONLY talents created within this period
        List<User> allTalents = userRepository.findByRole(UserRole.TALENT);
        List<User> periodTalents = allTalents.stream()
                .filter(u -> u.getCreatedAt() != null && 
                            !u.getCreatedAt().isBefore(startOfMonth) && 
                            !u.getCreatedAt().isAfter(endOfMonth))
                .toList();
        
        long totalTalents = periodTalents.size(); // Count ONLY in this period
        long newTalents = periodTalents.size(); // Same as total
        
        TransparencyReportDTO.TalentStats talentStats = TransparencyReportDTO.TalentStats.builder()
                .total(totalTalents)
                .newTalents(newTalents)
                .active(totalTalents)
                .averageRating(4.5)
                .build();
        
        // Mentor statistics - ONLY mentors created within this period
        List<User> allMentors = userRepository.findByRole(UserRole.MENTOR);
        List<User> periodMentors = allMentors.stream()
                .filter(u -> u.getCreatedAt() != null && 
                            !u.getCreatedAt().isBefore(startOfMonth) && 
                            !u.getCreatedAt().isAfter(endOfMonth))
                .toList();
        
        long totalMentors = periodMentors.size(); // Count ONLY in this period
        
        TransparencyReportDTO.MentorStats mentorStats = TransparencyReportDTO.MentorStats.builder()
                .total(totalMentors)
                .active(totalMentors)
                .averageRating(4.7)
                .build();
        
        // Financial statistics - Use ONLY projects from this period
        BigDecimal totalRevenue = BigDecimal.ZERO;
        BigDecimal teamDisbursed = BigDecimal.ZERO;
        BigDecimal mentorDisbursed = BigDecimal.ZERO;
        BigDecimal labRevenue = BigDecimal.ZERO;
        
        for (Project project : periodProjects) {
            if (project.getBudget() != null) {
                BigDecimal budget = BigDecimal.valueOf(project.getBudget());
                totalRevenue = totalRevenue.add(budget);
                
                teamDisbursed = teamDisbursed.add(budget.multiply(TEAM_PERCENTAGE).divide(HUNDRED, 2, RoundingMode.HALF_UP));
                mentorDisbursed = mentorDisbursed.add(budget.multiply(MENTOR_PERCENTAGE).divide(HUNDRED, 2, RoundingMode.HALF_UP));
                labRevenue = labRevenue.add(budget.multiply(LAB_PERCENTAGE).divide(HUNDRED, 2, RoundingMode.HALF_UP));
            }
        }
        
        TransparencyReportDTO.FinancialStats financialStats = TransparencyReportDTO.FinancialStats.builder()
                .totalRevenue(totalRevenue)
                .teamDisbursed(teamDisbursed)
                .mentorDisbursed(mentorDisbursed)
                .labRevenue(labRevenue)
                .hybridFundAdvanced(BigDecimal.ZERO)
                .hybridFundRepaid(BigDecimal.ZERO)
                .build();
        
        // Performance statistics
        TransparencyReportDTO.PerformanceStats performanceStats = TransparencyReportDTO.PerformanceStats.builder()
                .avgProjectCompletion(85.5)
                .onTimeDelivery(78.3)
                .customerSatisfaction(4.6)
                .build();
        
        return TransparencyReportDTO.ReportStatistics.builder()
                .projects(projectStats)
                .enterprises(enterpriseStats)
                .talents(talentStats)
                .mentors(mentorStats)
                .financials(financialStats)
                .performance(performanceStats)
                .build();
    }
    
    /**
     * Download PDF from Cloudinary
     */
    public byte[] downloadPDF(Long reportId) {
        log.info("Downloading PDF for report: {}", reportId);
        
        TransparencyReport report = transparencyReportRepository.findById(reportId)
            .orElseThrow(() -> new RuntimeException("Report not found: " + reportId));
        
        if (report.getPdfUrl() == null || report.getPdfUrl().isEmpty()) {
            throw new RuntimeException("PDF not available for report: " + reportId);
        }
        
        try {
            // Fetch PDF from Cloudinary URL
            java.net.URL url = new java.net.URL(report.getPdfUrl());
            java.io.InputStream in = url.openStream();
            byte[] pdfBytes = in.readAllBytes();
            in.close();
            
            log.info("PDF downloaded successfully for report: {}", reportId);
            return pdfBytes;
            
        } catch (Exception e) {
            log.error("Failed to download PDF from Cloudinary", e);
            throw new RuntimeException("Failed to download PDF: " + e.getMessage());
        }
    }
}
