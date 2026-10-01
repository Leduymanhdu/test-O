package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "team_fund_distributions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TeamFundDistribution {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "project_id", nullable = false)
    private Long projectId;
    
    @Column(name = "allocation_id", nullable = false)
    private Long allocationId;
    
    @Column(name = "submitted_by", nullable = false)
    private Long submittedBy;
    
    @Column(name = "total_team_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalTeamAmount;
    
    @Column(length = 50)
    private String status = "DRAFT";
    
    @Column(name = "approved_by_mentor")
    private Long approvedByMentor;
    
    @Column(name = "approved_by_mentor_at")
    private LocalDateTime approvedByMentorAt;
    
    @Column(name = "approved_by_lab")
    private Long approvedByLab;
    
    @Column(name = "approved_by_lab_at")
    private LocalDateTime approvedByLabAt;
    
    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
