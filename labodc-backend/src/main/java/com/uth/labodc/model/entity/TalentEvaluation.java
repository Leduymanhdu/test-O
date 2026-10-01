package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "talent_evaluations",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"project_id", "talent_id", "evaluation_period"})
    }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TalentEvaluation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "project_id", nullable = false)
    private Long projectId;

    @Column(name = "talent_id", nullable = false)
    private Long talentId;

    @Column(name = "mentor_id", nullable = false)
    private Long mentorId;

    @Column(name = "evaluation_period", nullable = false)
    private String evaluationPeriod; // YYYY-MM

    @Column(name = "overall_score")
    private Double overallScore;

    @Column(name = "technical_skills", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String technicalSkills;

    @Column(name = "problem_solving", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String problemSolving;

    @Column(name = "teamwork", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String teamwork;

    @Column(name = "communication", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String communication;

    @Column(name = "code_quality", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String codeQuality;

    @Column(name = "punctuality", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String punctuality;

    @Column(name = "strengths", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String strengths;

    @Column(name = "weaknesses", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String weaknesses;

    @Column(name = "recommendations", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String recommendations;

    @Column(name = "tasks_completed")
    private Integer tasksCompleted;

    @Column(name = "tasks_total")
    private Integer tasksTotal;

    @Column(name = "hours_worked")
    private Integer hoursWorked;

    @Column(name = "grade")
    private String grade; // A|B|C|D|F

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
