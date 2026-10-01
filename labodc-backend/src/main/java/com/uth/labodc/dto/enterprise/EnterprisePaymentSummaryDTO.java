package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterprisePaymentSummaryDTO {
    private long paid;
    private long pending;
    private long overdue;
    private double remaining;
}
