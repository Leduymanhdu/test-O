package com.uth.labodc.project.model;

import jakarta.persistence.*;

@Entity
@Table(
        name = "project_members",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_project_members_project_user", columnNames = {"projectId", "userId"})
        },
        indexes = {
                @Index(name = "idx_project_members_project_id", columnList = "projectId"),
                @Index(name = "idx_project_members_user_id", columnList = "userId")
        }
)
public class ProjectMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long projectId;

    @Column(nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ProjectMemberRole role;

    protected ProjectMember() {
    }

    public ProjectMember(Long projectId, Long userId, ProjectMemberRole role) {
        this.projectId = projectId;
        this.userId = userId;
        this.role = role;
    }

    public Long getId() {
        return id;
    }

    public Long getProjectId() {
        return projectId;
    }

    public Long getUserId() {
        return userId;
    }

    public ProjectMemberRole getRole() {
        return role;
    }
}
