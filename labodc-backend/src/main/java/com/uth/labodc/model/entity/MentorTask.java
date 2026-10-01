package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "mentor_tasks")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MentorTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "mentor_id", nullable = false)
    private Long mentorId;

    @Column(name = "project_id")
    private Long projectId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "status", nullable = false)
    private String status = "pending";

    @Column(name = "progress", nullable = false)
    private Integer progress = 0;

    @Column(name = "assigned_to", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String assignedTo = "[]";

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(name = "priority", nullable = false)
    private String priority = "medium";

    @Column(name = "project_name")
    private String projectName;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
