package com.uth.labodc.model.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "mentor_reports")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MentorReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "mentor_id", nullable = false)
    private Long mentorId;

    @Column(name = "project_id")
    private Long projectId;

    @Column(name = "student", nullable = false)
    private String student;

    @Column(name = "student_id", nullable = false)
    private String studentId;

    @Column(name = "report_name", nullable = false)
    private String reportName;

    @Column(name = "status", nullable = false)
    private String status = "pending";

    @Column(name = "submitted_date")
    private LocalDate submittedDate;

    @Column(name = "due_date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "score")
    private Double score;

    @Column(name = "file_size")
    private String fileSize;

    @Column(name = "summary", columnDefinition = "TEXT")
    private String summary;

    @Column(name = "file_path", length = 500)
    private String filePath;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
