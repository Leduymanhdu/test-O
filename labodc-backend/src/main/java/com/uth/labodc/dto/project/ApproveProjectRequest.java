package com.uth.labodc.dto.project;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApproveProjectRequest {
    private String note;
    private AdjustmentsDTO adjustments;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdjustmentsDTO {
        private Integer numberOfStudents;
        private String duration;
    }
}
