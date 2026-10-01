package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "enterprise_rejections")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseRejection {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "enterprise_id")
    private Long enterpriseId;
    
    @Column(name = "rejected_by", nullable = false)
    private Long rejectedBy;
    
    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;
    
    @Column(name = "rejected_at")
    private LocalDateTime rejectedAt;
    
    // Store enterprise info before deletion
    @Column(name = "company_name")
    private String companyName;
    
    @Column(name = "tax_code")
    private String taxCode;
    
    @Column(name = "contact_email")
    private String contactEmail;
    
    @PrePersist
    protected void onCreate() {
        if (rejectedAt == null) {
            rejectedAt = LocalDateTime.now();
        }
    }
}
