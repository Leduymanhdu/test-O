package com.uth.labodc.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectDTO {
    private Long id;
    
    // Related Entities
    private Long enterpriseId;
    private String enterpriseName;
    private Long mentorId;
    private String mentorName;
    
    // Basic Info
    private String title;
    private String slug;
    private String description;
    private String objectives;
    private String requirements;
    
    // Timeline
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer durationWeeks;
    
    // Financial
    private Double budget;
    private String currency;
    
    // Team
    private Integer numberOfStudents;
    private Integer currentMembers;
    private List<Long> talentIds;
    private List<String> talentNames;
    
    // Technologies
    private List<String> technologies;
    private String primaryTechnology;
    
    // Status
    private String status; // DRAFT, OPEN, IN_PROGRESS, COMPLETED, CANCELLED
    private Integer progressPercentage;
    
    // Validation
    private String validated; // pending, approved, rejected
    private LocalDateTime validatedAt;
    private Long validatedBy;
    private String validatedByName;
    
    // Milestones Count
    private Integer totalMilestones;
    private Integer completedMilestones;
    
    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
