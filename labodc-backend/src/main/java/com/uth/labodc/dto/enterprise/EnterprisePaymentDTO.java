package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterprisePaymentDTO {
    private String key;
    private String code;
    private String project;
    private double amount;
    private LocalDateTime dueDate;
    private String status;
}
