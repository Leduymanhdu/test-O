package com.uth.labodc.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RevenueChartDTO {
    private String month;
    private long revenue;
    private long teamDisbursed;
    private long mentorDisbursed;
    private long labRevenue;
}
