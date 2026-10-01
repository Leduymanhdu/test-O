package com.uth.labodc.dto.project;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectResponse {
    private Long id;
    private String name;
    private String description;
    private String objective;
    @Builder.Default
    private List<String> technologies = new ArrayList<>();
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Double budget;
    private Integer requiredTalents;
    @Builder.Default
    private List<String> requiredSkills = new ArrayList<>();
    private String status;
    private Long enterpriseId;
    private Long mentorId;
    private String mentorName;
    @Builder.Default
    private List<String> attachments = new ArrayList<>();
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String validated; // pending, approved, rejected
    private String rejectionReason;
    private Integer progressPercentage;
}
