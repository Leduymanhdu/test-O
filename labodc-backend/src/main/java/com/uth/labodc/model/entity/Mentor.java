package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "mentors")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Mentor {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", unique = true, nullable = false)
    private Long userId;
    
    @Column(name = "full_name", nullable = false)
    private String fullName;
    
    @Column(name = "title")
    private String title;
    
    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;
    
    @Column(name = "years_of_experience")
    private Integer yearsOfExperience;
    
    @Column(name = "current_position")
    private String currentPosition;
    
    @Column(name = "current_company")
    private String currentCompany;
    
    @Column(name = "linkedin_url")
    private String linkedinUrl;
    
    @Column(name = "max_concurrent_projects")
    private Integer maxConcurrentProjects;
    
    @Column(name = "hourly_rate")
    private Long hourlyRate;
    
    @Column(name = "available")
    private Boolean available = true;
    
    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage = BigDecimal.ZERO;
    
    @Column(name = "total_projects")
    private Integer totalProjects = 0;
    
    @Column(name = "current_projects_count")
    private Integer currentProjectsCount = 0;
    
    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
