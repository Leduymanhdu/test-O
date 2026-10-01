package com.uth.labodc.dto.project;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectValidationDTO {
    private Long id;
    private String title;
    private String description;
    private EnterpriseBasicDTO enterprise;
    private LocalDate startDate;
    private LocalDate endDate;
    private String duration;
    private BigDecimal budget;
    private Integer numberOfStudents;
    private String status;
    private LocalDateTime submittedAt;
    private Double feasibilityScore;
    private String validated; // pending, approved, rejected
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EnterpriseBasicDTO {
        private Long id;
        private String name;
        private String logoUrl;
        private Boolean verified;
    }
}
