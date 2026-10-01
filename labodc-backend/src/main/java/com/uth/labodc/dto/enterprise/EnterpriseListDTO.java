package com.uth.labodc.dto.enterprise;

import com.uth.labodc.model.enums.EnterpriseStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseListDTO {
    private Long id;
    private Long userId;
    private String companyName;
    private String taxCode;
    private String contactEmail;
    private String contactPhone;
    private String industry;
    private String companySize;
    private EnterpriseStatus status;
    private LocalDateTime verifiedAt;
    private LocalDateTime createdAt;
    private Integer totalProjects;
    private Integer activeProjects;
    private Long totalBudget;
}
