package com.uth.labodc.user.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateMeRequest(
        @NotBlank String fullName,
        String skills,
        String portfolioUrl
) {
}
