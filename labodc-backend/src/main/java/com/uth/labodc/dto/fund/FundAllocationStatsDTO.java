package com.uth.labodc.dto.fund;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FundAllocationStatsDTO {
    private Long totalAllocations;
    private BigDecimal totalAmount;
    private BigDecimal teamDisbursed;
    private BigDecimal mentorDisbursed;
    private BigDecimal labReceived;
    private Long pendingDistributions;
}
