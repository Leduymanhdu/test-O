package com.uth.labodc.dto.talent;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TalentProjectDTO {
    private Long id;
    private String title;
    private String description;
    private CompanyInfo company;
    private List<String> technologies;
    private LocalDate startDate;
    private LocalDate endDate;
    private String duration;
    private BigDecimal budget;
    private String allowancePerStudent;
    private Integer numberOfStudents;
    private Integer spotsAvailable;
    private List<String> skillRequirements;
    private String status;
    private String memberStatus; // For my projects: PENDING, APPROVED, ACTIVE
    private String memberRole;   // MEMBER, LEADER
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CompanyInfo {
        private String name;
        private String logoUrl;
    }
}