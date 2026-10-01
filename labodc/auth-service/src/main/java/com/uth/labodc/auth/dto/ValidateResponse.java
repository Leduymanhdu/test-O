package com.uth.labodc.auth.dto;

public record ValidateResponse(
        boolean valid,
        String userId,
        String email,
        String role
) {
}
