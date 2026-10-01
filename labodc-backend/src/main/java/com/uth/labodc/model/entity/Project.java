package com.uth.labodc.model.entity;

import com.uth.labodc.model.enums.ProjectStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "projects")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Project {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "enterprise_id", nullable = false)
    private Long enterpriseId;
    
    @Column(name = "mentor_id")
    private Long mentorId;
    
    @Column(name = "title", nullable = false)
    private String title;
    
    @Column(name = "slug", unique = true, nullable = false)
    private String slug;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "objectives", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String objectives;
    
    @Column(name = "requirements", columnDefinition = "TEXT")
    private String requirements;
    
    @Column(name = "start_date")
    private LocalDate startDate;
    
    @Column(name = "end_date")
    private LocalDate endDate;
    
    @Column(name = "actual_start_date")
    private LocalDate actualStartDate;
    
    @Column(name = "actual_end_date")
    private LocalDate actualEndDate;
    
    @Column(name = "budget")
    private Long budget;
    
    @Column(name = "currency")
    private String currency = "VND";
    
    @Column(name = "number_of_students")
    private Integer numberOfStudents;
    
    @Column(name = "current_members_count")
    private Integer currentMembersCount = 0;
    
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "status", nullable = false, columnDefinition = "project_status_enum")
    private ProjectStatus status;
    
    @Column(name = "progress_percentage")
    private Integer progressPercentage = 0;
    
    @Column(name = "validated", nullable = false)
    private String validated = "pending"; // pending, approved, rejected
    
    @Column(name = "validated_at")
    private LocalDateTime validatedAt;
    
    @Column(name = "validated_by")
    private Long validatedBy;
    
    @Column(name = "validation_note", columnDefinition = "TEXT")
    private String validationNote;
    
    @Column(name = "is_public")
    private Boolean isPublic = true;
    
    @Column(name = "allow_applications")
    private Boolean allowApplications = true;
    
    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "published_at")
    private LocalDateTime publishedAt;
    
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
    
    // Transient fields for rejection info (loaded from project_rejections table)
    @Transient
    private String rejectionReason;
    
    @Transient
    private LocalDateTime rejectedAt;
    
    @Transient
    private Long rejectedBy;
    
    // Transient field for technologies (loaded from project_technologies table)
    @Transient
    private java.util.List<String> technologies;
}
