package com.uth.labodc.user.dto;

public record UserProfileResponse(
        String id,
        String fullName,
        String email,
        String role,
        String skills,
        String portfolioUrl
) {
}
