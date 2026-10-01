package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "project_id", nullable = false)
    private Long projectId;
    
    @Column(name = "enterprise_id", nullable = false)
    private Long enterpriseId;
    
    @Column(name = "payment_code", nullable = false, unique = true, length = 50)
    private String paymentCode;
    
    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;
    
    @Column(length = 10)
    private String currency = "VND";
    
    @Column(name = "payos_order_id", length = 100)
    private String payosOrderId;
    
    @Column(name = "payos_transaction_id", length = 100)
    private String payosTransactionId;
    
    @Column(name = "payos_payment_link", length = 500)
    private String payosPaymentLink;
    
    @Column(nullable = false, length = 50)
    private String status = "PENDING";
    
    @Column(name = "payment_method", length = 50)
    private String paymentMethod;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "payment_link_expires_at")
    private LocalDateTime paymentLinkExpiresAt;
    
    @Column(name = "paid_at")
    private LocalDateTime paidAt;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(columnDefinition = "TEXT")
    private String note;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
