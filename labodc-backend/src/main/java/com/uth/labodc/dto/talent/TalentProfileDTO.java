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
public class TalentProfileDTO {
    private Long id;
    private String fullName;
    private String studentId;
    private String faculty;
    private String major;
    private Integer yearOfStudy;
    private String email;
    private String phone;
    private String avatarUrl;
    private String cvUrl;
    private String portfolioUrl;
    private String githubUrl;
    private String linkedinUrl;
    private String bio;
    private BigDecimal gpa;
    private LocalDate dateOfBirth;
    private LocalDate expectedGraduation;
    private Boolean availableForProjects;
    private String workAvailability;
    private Integer hoursPerWeek;
    private List<TalentSkillDTO> skills;
    private List<TalentCertificationDTO> certifications;
    private Integer projectsCompleted;
    private BigDecimal averageRating;
    private String status;
}