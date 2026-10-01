package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "talents")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Talent {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", unique = true, nullable = false)
    private Long userId;
    
    @Column(name = "full_name", nullable = false)
    private String fullName;
    
    @Column(name = "student_id")
    private String studentId;
    
    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;
    
    @Column(name = "faculty")
    private String faculty;
    
    @Column(name = "major")
    private String major;
    
    @Column(name = "year_of_study")
    private Integer yearOfStudy;
    
    @Column(name = "gpa", precision = 3, scale = 2)
    private BigDecimal gpa;
    
    @Column(name = "github_url")
    private String githubUrl;
    
    @Column(name = "linkedin_url")
    private String linkedinUrl;
    
    @Column(name = "portfolio_url")
    private String portfolioUrl;
    
    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;
    
    @Column(name = "expected_graduation")
    private LocalDate expectedGraduation;
    
    @Column(name = "available_for_projects")
    private Boolean availableForProjects = true;
    
    @Column(name = "work_availability")
    private String workAvailability;
    
    @Column(name = "hours_per_week")
    private Integer hoursPerWeek;
    
    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage = BigDecimal.ZERO;
    
    @Column(name = "total_projects")
    private Integer totalProjects = 0;
    
    @Column(name = "completed_projects")
    private Integer completedProjects = 0;
    
    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
