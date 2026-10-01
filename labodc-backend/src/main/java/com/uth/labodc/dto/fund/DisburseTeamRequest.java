package com.uth.labodc.dto.fund;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DisburseTeamRequest {
    private Long distributionId;
    private List<TeamMemberDisbursement> teamDistribution;
    private String note;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeamMemberDisbursement {
        private Long talentId;
        private BigDecimal amount;
    }
}
