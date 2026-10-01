package com.uth.labodc.dto.talent;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class FundDistributionRequest {
    @NotBlank
    private String talentId;
    
    @NotNull
    @Positive
    private Double amount;
    
    private String description;
    
    private String justification;
}