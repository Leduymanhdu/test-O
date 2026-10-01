package com.uth.labodc.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransparencyReportDTO {
    private Long reportId;
    private String reportType;
    private String period;
    private ReportStatistics statistics;
    private String status;
    private String publishNote;
    private Long createdBy;
    private LocalDateTime publishedAt;
    private String publicUrl;
    private String pdfUrl;
    private LocalDateTime createdAt;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReportStatistics {
        private ProjectStats projects;
        private EnterpriseStats enterprises;
        private TalentStats talents;
        private MentorStats mentors;
        private FinancialStats financials;
        private PerformanceStats performance;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProjectStats {
        private Long total;
        private Long newProjects;
        private Long ongoing;
        private Long completed;
        private Long cancelled;
        private Double successRate;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EnterpriseStats {
        private Long total;
        private Long newEnterprises;
        private Long active;
        private Long verified;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TalentStats {
        private Long total;
        private Long newTalents;
        private Long active;
        private Double averageRating;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MentorStats {
        private Long total;
        private Long active;
        private Double averageRating;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FinancialStats {
        private BigDecimal totalRevenue;
        private BigDecimal teamDisbursed;
        private BigDecimal mentorDisbursed;
        private BigDecimal labRevenue;
        private BigDecimal hybridFundAdvanced;
        private BigDecimal hybridFundRepaid;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PerformanceStats {
        private Double avgProjectCompletion;
        private Double onTimeDelivery;
        private Double customerSatisfaction;
    }
}
