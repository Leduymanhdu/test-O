package com.uth.labodc.project.dto;

import com.uth.labodc.project.model.ProjectStatus;

import java.time.Instant;

public record ProjectResponse(
        Long id,
        String name,
        String description,
        Long enterpriseId,
        Long mentorId,
        ProjectStatus status,
        Instant createdAt
) {
}
