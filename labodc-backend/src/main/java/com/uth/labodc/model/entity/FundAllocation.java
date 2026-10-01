package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fund_allocations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FundAllocation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "project_id", nullable = false, unique = true)
    private Long projectId;
    
    @Column(name = "payment_id", nullable = false)
    private Long paymentId;
    
    @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;
    
    // Team allocation (70%)
    @Column(name = "team_percentage", precision = 5, scale = 2)
    private BigDecimal teamPercentage = new BigDecimal("70.00");
    
    @Column(name = "team_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal teamAmount;
    
    // Mentor allocation (20%)
    @Column(name = "mentor_percentage", precision = 5, scale = 2)
    private BigDecimal mentorPercentage = new BigDecimal("20.00");
    
    @Column(name = "mentor_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal mentorAmount;
    
    // Lab allocation (10%)
    @Column(name = "lab_percentage", precision = 5, scale = 2)
    private BigDecimal labPercentage = new BigDecimal("10.00");
    
    @Column(name = "lab_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal labAmount;
    
    @Column(length = 50)
    private String status = "ALLOCATED";
    
    @Column(name = "validated_by")
    private Long validatedBy;
    
    @Column(name = "validated_at")
    private LocalDateTime validatedAt;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
