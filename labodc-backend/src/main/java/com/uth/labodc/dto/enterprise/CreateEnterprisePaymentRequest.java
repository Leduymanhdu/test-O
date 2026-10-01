package com.uth.labodc.dto.enterprise;

import lombok.Data;

import java.time.LocalDate;

@Data
public class CreateEnterprisePaymentRequest {
    private Long projectId;
    private Double amount;
    private LocalDate dueDate;
    private String description;
    private String paymentMethod;
}
