package com.uth.labodc.dto.project;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectStatsDTO {
    private long total;
    private long pending;
    private long validated;
    private long recruiting;
    private long inProgress;
    private long completed;
}
