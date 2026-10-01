package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "project_rejections")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectRejection {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "project_id")
    private Long projectId;
    
    @Column(name = "rejected_by", nullable = false)
    private Long rejectedBy;
    
    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;
    
    @Column(name = "rejected_at")
    private LocalDateTime rejectedAt;
    
    // Store project info before deletion
    @Column(name = "title")
    private String title;
    
    @Column(name = "slug")
    private String slug;
    
    @Column(name = "enterprise_name")
    private String enterpriseName;
    
    @PrePersist
    protected void onCreate() {
        if (rejectedAt == null) {
            rejectedAt = LocalDateTime.now();
        }
    }
}
