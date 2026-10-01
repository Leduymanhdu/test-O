package com.uth.labodc.service;

import com.uth.labodc.dto.dashboard.*;
import com.uth.labodc.model.entity.Enterprise;
import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.enums.EnterpriseStatus;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardService {
    
    private final ProjectRepository projectRepository;
    private final EnterpriseRepository enterpriseRepository;
    private final TalentRepository talentRepository;
    private final MentorRepository mentorRepository;
    private final UserRepository userRepository;
    private final PaymentRepository paymentRepository;
    private final FundDistributionRepository fundDistributionRepository;
    private final JdbcTemplate jdbcTemplate;
    
    @Transactional(readOnly = true)
    public DashboardStatsDTO getDashboardStats() {
        log.info("Fetching dashboard statistics...");
        
        try {
            LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
            
            // Project Stats
            long totalProjects = projectRepository.count();
            long newProjects = projectRepository.countNewProjects(thirtyDaysAgo);
            long ongoingProjects = projectRepository.countByStatus(ProjectStatus.IN_PROGRESS);
            long completedProjects = projectRepository.countByStatus(ProjectStatus.COMPLETED);
            long cancelledProjects = projectRepository.countByStatus(ProjectStatus.CANCELLED);
            
            double successRate = 0.0;
            if (totalProjects > 0) {
                successRate = ((double) completedProjects / totalProjects) * 100;
                successRate = Math.round(successRate * 10.0) / 10.0;
            }
            
            DashboardStatsDTO.ProjectStats projectStats = DashboardStatsDTO.ProjectStats.builder()
                    .total(totalProjects)
                    .newCount(newProjects)
                    .ongoing(ongoingProjects)
                    .completed(completedProjects)
                    .cancelled(cancelledProjects)
                    .successRate(successRate)
                    .build();
            
            // Enterprise Stats
            long totalEnterprises = enterpriseRepository.count();
            long newEnterprises = enterpriseRepository.countNewEnterprises(thirtyDaysAgo);
            long activeEnterprises = 0; // Simplified - will fix later
            try {
                activeEnterprises = enterpriseRepository.countActiveEnterprises();
            } catch (Exception e) {
                log.warn("Could not count active enterprises: {}", e.getMessage());
                activeEnterprises = totalEnterprises; // Fallback
            }
            long verifiedEnterprises = enterpriseRepository.countByStatus(EnterpriseStatus.APPROVED);
            
            DashboardStatsDTO.EnterpriseStats enterpriseStats = DashboardStatsDTO.EnterpriseStats.builder()
                    .total(totalEnterprises)
                    .newCount(newEnterprises)
                    .active(activeEnterprises)
                    .verified(verifiedEnterprises)
                    .build();
            
            // Talent Stats
            long totalTalents = talentRepository.count();
            long newTalents = talentRepository.countNewTalents(thirtyDaysAgo);
            long activeTalents = 0;
            try {
                activeTalents = talentRepository.countActiveTalents();
            } catch (Exception e) {
                log.warn("Could not count active talents: {}", e.getMessage());
                activeTalents = totalTalents; // Fallback
            }
            
            BigDecimal avgTalentRating = talentRepository.getAverageRating();
            double talentRating = avgTalentRating != null ? avgTalentRating.doubleValue() : 0.0;
            talentRating = Math.round(talentRating * 10.0) / 10.0;
            
            DashboardStatsDTO.TalentStats talentStats = DashboardStatsDTO.TalentStats.builder()
                    .total(totalTalents)
                    .newCount(newTalents)
                    .active(activeTalents)
                    .averageRating(talentRating)
                    .build();
            
            // Mentor Stats
            long totalMentors = mentorRepository.count();
            long activeMentors = mentorRepository.countByAvailable(true);
            
            BigDecimal avgMentorRating = mentorRepository.getAverageRating();
            double mentorRating = avgMentorRating != null ? avgMentorRating.doubleValue() : 0.0;
            mentorRating = Math.round(mentorRating * 10.0) / 10.0;
            
            DashboardStatsDTO.MentorStats mentorStats = DashboardStatsDTO.MentorStats.builder()
                    .total(totalMentors)
                    .active(activeMentors)
                    .averageRating(mentorRating)
                    .build();
            
            // Financial Stats
            BigDecimal totalRevenueAmount = safeSumPayments("COMPLETED");
            BigDecimal teamDisbursedAmount = safeSumDistributions(List.of("TEAM", "TALENT"), "COMPLETED");
            BigDecimal mentorDisbursedAmount = safeSumDistributions(List.of("MENTOR"), "COMPLETED");
            BigDecimal labRevenueAmount = safeSumDistributions(List.of("LAB"), "COMPLETED");

            BigDecimal hybridAdvancedAmount = queryBigDecimal(
                    "SELECT COALESCE(SUM(advance_amount), 0) FROM hybrid_fund_advances");
            BigDecimal hybridRepaidAmount = queryBigDecimal(
                    "SELECT COALESCE(SUM(repaid_amount), 0) FROM hybrid_fund_advances");
            
            DashboardStatsDTO.FinancialStats financialStats = DashboardStatsDTO.FinancialStats.builder()
                    .totalRevenue(toLong(totalRevenueAmount))
                    .teamDisbursed(toLong(teamDisbursedAmount))
                    .mentorDisbursed(toLong(mentorDisbursedAmount))
                    .labRevenue(toLong(labRevenueAmount))
                    .hybridFundAdvanced(toLong(hybridAdvancedAmount))
                    .hybridFundRepaid(toLong(hybridRepaidAmount))
                    .build();
            
            // Performance Stats (placeholder)
            DashboardStatsDTO.PerformanceStats performanceStats = DashboardStatsDTO.PerformanceStats.builder()
                    .avgProjectCompletion(0.0)
                    .onTimeDelivery(0.0)
                    .customerSatisfaction(0.0)
                    .build();
            
            DashboardStatsDTO stats = DashboardStatsDTO.builder()
                    .projects(projectStats)
                    .enterprises(enterpriseStats)
                    .talents(talentStats)
                    .mentors(mentorStats)
                    .financials(financialStats)
                    .performance(performanceStats)
                    .build();
            
            log.info("Dashboard statistics fetched successfully");
            return stats;
        } catch (Exception e) {
            log.error("Error fetching dashboard stats", e);
            throw e;
        }
    }
    
    @Transactional(readOnly = true)
    public List<RecentActivityDTO> getRecentActivities(int limit) {
        log.info("Fetching recent activities, limit: {}", limit);
        
        List<RecentActivityDTO> activities = new ArrayList<>();
        
        // Get recent projects
        List<Project> recentProjects = projectRepository.findRecentProjects(PageRequest.of(0, limit));
        
        for (Project project : recentProjects) {
            String description = String.format("Dự án mới được tạo bởi DN #%d", project.getEnterpriseId());
            String status = "info";
            
            if (project.getStatus() == ProjectStatus.COMPLETED) {
                description = String.format("Dự án hoàn thành thành công");
                status = "success";
            } else if (project.getStatus() == ProjectStatus.RECRUITING) {
                description = String.format("Dự án đang tuyển thành viên");
                status = "warning";
            }
            
            activities.add(RecentActivityDTO.builder()
                    .id(project.getId())
                    .type("project")
                    .title(project.getTitle())
                    .description(description)
                    .timestamp(project.getCreatedAt())
                    .status(status)
                    .build());
        }
        
        log.info("Found {} recent activities", activities.size());
        return activities;
    }
    
    @Transactional(readOnly = true)
    public List<PendingApprovalDTO> getPendingApprovals(int limit) {
        log.info("Fetching pending approvals, limit: {}", limit);
        
        List<PendingApprovalDTO> approvals = new ArrayList<>();
        
        // Get pending enterprises
        List<Enterprise> pendingEnterprises = enterpriseRepository.findAll().stream()
                .filter(e -> EnterpriseStatus.PENDING.equals(e.getStatus()))
                .limit(limit / 2)
                .toList();
        
        for (Enterprise enterprise : pendingEnterprises) {
            approvals.add(PendingApprovalDTO.builder()
                    .id(enterprise.getId())
                    .type("enterprise")
                    .title(enterprise.getCompanyName())
                    .submittedAt(enterprise.getCreatedAt())
                    .priority("high")
                    // Enterprise details
                    .companyName(enterprise.getCompanyName())
                    .taxCode(enterprise.getTaxCode())
                    .businessLicenseNumber(enterprise.getBusinessLicenseNumber())
                    .address(enterprise.getAddress())
                    .city(enterprise.getCity())
                    .district(enterprise.getDistrict())
                    .ward(enterprise.getWard())
                    .representativeName(enterprise.getRepresentativeName())
                    .representativePosition(enterprise.getRepresentativePosition())
                    .contactEmail(enterprise.getContactEmail())
                    .contactPhone(enterprise.getContactPhone())
                    .website(enterprise.getWebsite())
                    .industry(enterprise.getIndustry())
                    .companySize(enterprise.getCompanySize())
                    .yearEstablished(enterprise.getYearEstablished())
                    .description(enterprise.getDescription())
                    .build());
        }
        
        // Get pending project validations
        List<Project> pendingProjects = projectRepository.findPendingValidation(PageRequest.of(0, limit / 2));
        
        for (Project project : pendingProjects) {
            // Get enterprise name
            String enterpriseName = "";
            try {
                Enterprise enterprise = enterpriseRepository.findById(project.getEnterpriseId()).orElse(null);
                if (enterprise != null) {
                    enterpriseName = enterprise.getCompanyName();
                }
            } catch (Exception e) {
                log.warn("Could not fetch enterprise for project {}", project.getId());
            }
            
            approvals.add(PendingApprovalDTO.builder()
                    .id(project.getId())
                    .type("project")
                    .title(project.getTitle())
                    .submittedAt(project.getCreatedAt())
                    .priority("medium")
                    // Project details
                    .slug(project.getSlug())
                    .description(project.getDescription())
                    .requirements(project.getRequirements())
                    .startDate(project.getStartDate())
                    .endDate(project.getEndDate())
                    .budget(project.getBudget())
                    .currency(project.getCurrency())
                    .numberOfStudents(project.getNumberOfStudents())
                    .status(project.getStatus().name())
                    .enterpriseName(enterpriseName)
                    .build());
        }
        
        log.info("Found {} pending approvals", approvals.size());
        return approvals;
    }
    
    @Transactional(readOnly = true)
    public List<RevenueChartDTO> getRevenueChart(int months) {
        log.info("Fetching revenue chart data for {} months", months);
        
        List<RevenueChartDTO> chartData = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/yyyy");
        
        try {
            // Get monthly revenue from database
            List<Object[]> monthlyData = projectRepository.getMonthlyRevenue(months);
            
            // Create map for quick lookup
            java.util.Map<String, Long> revenueMap = new java.util.HashMap<>();
            for (Object[] row : monthlyData) {
                String month = (String) row[0];
                Long revenue = ((Number) row[1]).longValue();
                revenueMap.put(month, revenue);
            }
            
            // Fill in all months, including those with no data
            LocalDateTime now = LocalDateTime.now();
            for (int i = months - 1; i >= 0; i--) {
                LocalDateTime monthDate = now.minusMonths(i);
                String monthKey = monthDate.format(formatter);
                
                Long revenue = revenueMap.getOrDefault(monthKey, 0L);
                long teamDisbursed = (long)(revenue * 0.70);
                long mentorDisbursed = (long)(revenue * 0.20);
                long labRevenue = (long)(revenue * 0.10);
                
                chartData.add(RevenueChartDTO.builder()
                        .month(monthKey)
                        .revenue(revenue)
                        .teamDisbursed(teamDisbursed)
                        .mentorDisbursed(mentorDisbursed)
                        .labRevenue(labRevenue)
                        .build());
            }
            
            log.info("Revenue chart data fetched: {} months", chartData.size());
        } catch (Exception e) {
            log.error("Error fetching revenue chart data", e);
            // Return empty data if error
            LocalDateTime now = LocalDateTime.now();
            for (int i = months - 1; i >= 0; i--) {
                LocalDateTime monthDate = now.minusMonths(i);
                chartData.add(RevenueChartDTO.builder()
                        .month(monthDate.format(formatter))
                        .revenue(0L)
                        .teamDisbursed(0L)
                        .mentorDisbursed(0L)
                        .labRevenue(0L)
                        .build());
            }
        }
        
        return chartData;
    }

    private BigDecimal queryBigDecimal(String sql) {
        try {
            BigDecimal value = jdbcTemplate.queryForObject(sql, BigDecimal.class);
            return value != null ? value : BigDecimal.ZERO;
        } catch (Exception e) {
            log.warn("Failed to query financial value: {}", e.getMessage());
            return BigDecimal.ZERO;
        }
    }

    private long toLong(BigDecimal value) {
        if (value == null) {
            return 0L;
        }
        return value.setScale(0, RoundingMode.HALF_UP).longValue();
    }

    private BigDecimal safeSumPayments(String status) {
        try {
            BigDecimal value = paymentRepository.sumAmountByStatus(status);
            return value != null ? value : BigDecimal.ZERO;
        } catch (Exception e) {
            log.warn("Failed to sum payments with status {}: {}", status, e.getMessage());
            return BigDecimal.ZERO;
        }
    }

    private BigDecimal safeSumDistributions(List<String> recipientTypes, String status) {
        try {
            BigDecimal value = fundDistributionRepository.sumAmountByRecipientTypesAndStatus(recipientTypes, status);
            return value != null ? value : BigDecimal.ZERO;
        } catch (Exception e) {
            log.warn("Failed to sum distributions {} with status {}: {}", recipientTypes, status, e.getMessage());
            return BigDecimal.ZERO;
        }
    }
}
