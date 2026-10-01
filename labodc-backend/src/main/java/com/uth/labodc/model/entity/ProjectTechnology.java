package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "project_technologies")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectTechnology {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "project_id", nullable = false)
    private Long projectId;
    
    @Column(name = "technology_name", nullable = false, length = 100)
    private String technologyName;
    
    @Column(name = "technology_type", length = 50)
    private String technologyType;
    
    @Column(name = "is_required")
    private Boolean isRequired;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
