package com.uth.labodc.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EnterpriseDTO {
    private Long id;
    private Long userId;
    private String userEmail;
    private String companyName;
    private String taxCode;
    private String businessLicenseNumber;
    
    // Address
    private String address;
    private String city;
    private String district;
    private String ward;
    
    // Representative
    private String representativeName;
    private String representativePosition;
    
    // Contact
    private String contactEmail;
    private String contactPhone;
    private String website;
    
    // Business Info
    private String industry;
    private String companySize;
    private Integer yearEstablished;
    private String description;
    
    // Verification - status: PENDING, APPROVED, REJECTED
    private String status;
    private LocalDateTime verifiedAt;
    private Long verifiedBy;
    private String verifiedByName;
    
    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Stats
    private Integer totalProjects;
    private Integer activeProjects;
}
