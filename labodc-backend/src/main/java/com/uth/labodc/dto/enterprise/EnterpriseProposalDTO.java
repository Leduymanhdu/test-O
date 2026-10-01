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
public class EnterpriseProposalDTO {
    private String key;
    private String name;
    private double budget;
    private String status;
    private LocalDateTime createdAt;
}
