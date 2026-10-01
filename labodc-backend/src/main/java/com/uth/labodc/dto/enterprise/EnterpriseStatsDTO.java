package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseStatsDTO {
    private Long total;
    private Long verified;
    private Long unverified;
    private Long active;
    private Long thisMonth;
}
