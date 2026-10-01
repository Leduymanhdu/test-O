package com.uth.labodc.dto.fund;

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
public class FundAllocationDTO {
    private Long projectId;
    private String projectTitle;
    private String enterpriseName;
    private PaymentInfo payment;
    private AllocationInfo allocation;
    private String status;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PaymentInfo {
        private Long id;
        private BigDecimal amount;
        private String status;
        private LocalDateTime paidAt;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AllocationInfo {
        private BigDecimal total;
        private FundPortion team;
        private FundPortion mentor;
        private FundPortion lab;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FundPortion {
        private BigDecimal amount;
        private Integer percentage;
        private String status;
    }
}
