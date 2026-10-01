package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "mentor_invitations")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MentorInvitation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "mentor_id", nullable = false)
    private Long mentorId;

    @Column(name = "project_id", nullable = false)
    private Long projectId;

    @Column(name = "invited_by", nullable = false)
    private Long invitedBy;

    @Column(name = "group_name", nullable = false)
    private String groupName;

    @Column(name = "student_count", nullable = false)
    private Integer studentCount = 0;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "deadline")
    private LocalDate deadline;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "skills", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private String skills = "[]";

    @Column(name = "received_date", nullable = false)
    private LocalDate receivedDate;

    @Column(name = "priority", nullable = false)
    private String priority = "medium";

    @Column(name = "status", nullable = false)
    private String status = "PENDING";

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
