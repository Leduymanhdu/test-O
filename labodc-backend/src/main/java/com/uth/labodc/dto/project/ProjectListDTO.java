package com.uth.labodc.dto.project;

import com.uth.labodc.model.enums.ProjectStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectListDTO {
    private Long id;
    private Long enterpriseId;
    private String title;
    private String description;
    private ProjectStatus status;
    private String validated; // pending, approved, rejected
    private LocalDateTime validatedAt;
    private Long budget;
    private Integer numberOfStudents;
    private Integer currentMembersCount;
    private Integer progressPercentage;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime createdAt;
    
    // Aggregated data
    private Integer totalTeamMembers;
    private Integer totalApplications;
    private List<String> technologies;
}
