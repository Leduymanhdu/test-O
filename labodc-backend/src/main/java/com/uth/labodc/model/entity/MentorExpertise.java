package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "mentor_expertise")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorExpertise {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "mentor_id", nullable = false)
    private Long mentorId;
    
    @Column(name = "skill_name", nullable = false, length = 100)
    private String skillName;
    
    @Column(name = "skill_category", length = 50)
    private String skillCategory;
    
    @Column(name = "proficiency_level")
    private String proficiencyLevel;
    
    @Column(name = "years_of_experience")
    private Double yearsOfExperience;
    
    @Column(name = "can_teach")
    private Boolean canTeach;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
