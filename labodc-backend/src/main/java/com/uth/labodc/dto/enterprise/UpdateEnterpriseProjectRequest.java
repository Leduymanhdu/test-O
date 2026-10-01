package com.uth.labodc.dto.enterprise;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class UpdateEnterpriseProjectRequest {
    private String name;
    private String description;
    private List<String> objectives;
    private String requirements;
    private LocalDate startDate;
    private LocalDate endDate;
    private Double budget;
    private Integer requiredTalents;
    private List<String> technologies;
    private List<String> requiredSkills;
    private Boolean allowApplications;
}
