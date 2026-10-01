package com.uth.labodc.auth.dto;

public record AuthResponse(
        String token,
        String tokenType,
        String email,
        String role
) {
}
