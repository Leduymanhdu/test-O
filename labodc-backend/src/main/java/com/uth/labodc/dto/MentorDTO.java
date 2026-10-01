package com.uth.labodc.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorDTO {
    private Long id;
    private Long userId;
    private String userEmail;
    
    // Personal Info
    private String fullName;
    private String title; // Dr., Mr., Ms., etc.
    private String avatar;
    
    // Professional Info
    private String currentPosition;
    private String currentCompany;
    private Integer yearsOfExperience;
    private String bio;
    
    // Contact
    private String linkedinUrl;
    private String portfolioUrl;
    
    // Expertise
    private List<String> expertise;
    private String topExpertise; // For search: comma-separated
    
    // Pricing
    private Double hourlyRate;
    private String currency;
    
    // Capacity
    private Integer maxConcurrentProjects;
    private Integer currentProjects;
    
    // Ratings
    private Double ratingAverage;
    private Integer totalRatings;
    
    // Stats
    private Integer totalProjects;
    private Integer completedProjects;
    
    // Status
    private Boolean available;
    private String status;
    
    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
