package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseProjectReportDTO {
    private String key;
    private String name;
    private double cost;
    private int progress;
    private String status;
}
