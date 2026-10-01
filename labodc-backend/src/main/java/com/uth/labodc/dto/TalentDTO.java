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
public class TalentDTO {
    private Long id;
    private Long userId;
    private String userEmail;
    
    // Personal Info
    private String fullName;
    private String studentId;
    private LocalDate dateOfBirth;
    private String avatar;
    
    // Academic Info
    private String faculty;
    private String major;
    private Integer yearOfStudy;
    private Double gpa;
    
    // Professional Links
    private String githubUrl;
    private String linkedinUrl;
    private String portfolioUrl;
    
    // Bio
    private String bio;
    
    // Skills
    private List<String> skills;
    private String topSkills; // For search: stored as comma-separated
    
    // Ratings
    private Double ratingAverage;
    private Integer totalRatings;
    
    // Project Stats
    private Integer totalProjects;
    private Integer completedProjects;
    private Integer ongoingProjects;
    
    // Status
    private Boolean available;
    private String status;
    
    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
