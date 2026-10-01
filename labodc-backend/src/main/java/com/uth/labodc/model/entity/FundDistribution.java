package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fund_distributions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FundDistribution {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "allocation_id", nullable = false)
    private Long allocationId;
    
    @Column(name = "recipient_type", nullable = false, length = 50)
    private String recipientType; // MENTOR, TALENT, LAB
    
    @Column(name = "recipient_id")
    private Long recipientId;
    
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;
    
    @Column(length = 50)
    private String status = "PENDING";
    
    @Column(name = "disbursed_at")
    private LocalDateTime disbursedAt;
    
    @Column(name = "disbursed_by")
    private Long disbursedBy;
    
    @Column(name = "payment_method", length = 50)
    private String paymentMethod;
    
    @Column(name = "transaction_reference", length = 100)
    private String transactionReference;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
