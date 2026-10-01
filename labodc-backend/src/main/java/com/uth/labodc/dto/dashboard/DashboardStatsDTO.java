package com.uth.labodc.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
    private ProjectStats projects;
    private EnterpriseStats enterprises;
    private TalentStats talents;
    private MentorStats mentors;
    private FinancialStats financials;
    private PerformanceStats performance;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProjectStats {
        private long total;
        private long newCount; // Projects created in last 30 days
        private long ongoing;
        private long completed;
        private long cancelled;
        private double successRate;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EnterpriseStats {
        private long total;
        private long newCount; // Enterprises created in last 30 days
        private long active;
        private long verified;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TalentStats {
        private long total;
        private long newCount; // Talents created in last 30 days
        private long active;
        private double averageRating;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MentorStats {
        private long total;
        private long active;
        private double averageRating;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FinancialStats {
        private long totalRevenue;
        private long teamDisbursed;
        private long mentorDisbursed;
        private long labRevenue;
        private long hybridFundAdvanced;
        private long hybridFundRepaid;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PerformanceStats {
        private double avgProjectCompletion;
        private double onTimeDelivery;
        private double customerSatisfaction;
    }
}
