package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseRecentProjectDTO {
    private Long id;
    private String name;
    private Integer progress;
    private Integer members;
    private String status;
}
