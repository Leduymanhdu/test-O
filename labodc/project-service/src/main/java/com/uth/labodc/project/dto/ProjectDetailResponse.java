package com.uth.labodc.project.dto;

import com.uth.labodc.project.model.ProjectStatus;

import java.time.Instant;
import java.util.List;

public record ProjectDetailResponse(
        Long id,
        String name,
        String description,
        Long enterpriseId,
        Long mentorId,
        ProjectStatus status,
        Instant createdAt,
        List<ProjectMemberResponse> members
) {
}
