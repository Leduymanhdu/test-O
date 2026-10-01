package com.uth.labodc.dto.project;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectValidationStatsDTO {
    private Long totalPending;
    private Long totalApproved;
    private Long totalRejected;
    private Long totalValidated;
    private Long thisMonth;
}
