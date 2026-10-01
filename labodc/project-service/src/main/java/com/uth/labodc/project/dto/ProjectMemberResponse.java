package com.uth.labodc.project.dto;

import com.uth.labodc.project.model.ProjectMemberRole;

public record ProjectMemberResponse(
        Long userId,
        ProjectMemberRole role
) {
}
