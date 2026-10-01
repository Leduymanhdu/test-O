package com.uth.labodc.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PendingApprovalDTO {
    private Long id;
    private String type; // 'enterprise' or 'project'
    private String title;
    private LocalDateTime submittedAt;
    private String priority; // 'high', 'medium', 'low'
    
    // Enterprise specific fields
    private String companyName;
    private String taxCode;
    private String businessLicenseNumber;
    private String address;
    private String city;
    private String district;
    private String ward;
    private String representativeName;
    private String representativePosition;
    private String contactEmail;
    private String contactPhone;
    private String website;
    private String industry;
    private String companySize;
    private Integer yearEstablished;
    private String description;
    
    // Project specific fields
    private String slug;
    private String requirements;
    private LocalDate startDate;
    private LocalDate endDate;
    private Long budget;
    private String currency;
    private Integer numberOfStudents;
    private String status;
    private String enterpriseName; // For displaying in project details
}
