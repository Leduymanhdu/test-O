package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseProjectItemDTO {
    private String key;
    private String name;
    private double budget;
    private double spent;
    private int progress;
    private String status;
    private Integer members;
    private String startDate;
    private String endDate;
}
