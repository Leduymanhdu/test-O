package com.uth.labodc.dto.talent;

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
public class TalentDashboardDTO {
    private TalentStatsDTO stats;
    private List<TalentProjectDTO> recentProjects;
    private List<TaskSummaryDTO> upcomingTasks;
    private List<String> notifications;
    private ProfileCompletionDTO profileCompletion;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TalentStatsDTO {
        private Integer totalProjects;
        private Integer completedProjects;
        private Integer ongoingProjects;
        private BigDecimal averageRating;
        private Integer totalSkills;
        private Integer totalCertifications;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TaskSummaryDTO {
        private Long taskId;
        private String taskName;
        private String projectName;
        private String dueDate;
        private String priority;
        private String status;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProfileCompletionDTO {
        private Integer percentage;
        private List<String> missingFields;
    }
}