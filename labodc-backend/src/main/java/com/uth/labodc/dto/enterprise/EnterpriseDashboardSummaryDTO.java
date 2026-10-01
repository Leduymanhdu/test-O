package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseDashboardSummaryDTO {
    private long totalProjects;
    private long activeProjects;
    private long completedProjects;
    private double totalSpent;
    private List<String> notifications;
}
