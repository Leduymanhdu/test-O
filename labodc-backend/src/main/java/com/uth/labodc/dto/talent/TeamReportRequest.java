package com.uth.labodc.dto.talent;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import lombok.Data;

import java.util.Map;

@Data
public class TeamReportRequest {
    @NotBlank
    private String reportPeriod; // "Week 1", "Month 1", etc.
    
    @NotNull
    @Min(0)
    @Max(100)
    private Integer progress; // 0-100%
    
    @NotBlank
    private String achievements;
    
    private String challenges;
    
    private String nextSteps;
    
    private Map<String, String> memberContributions; // talentId -> contribution description
    
    private String additionalNotes;
}