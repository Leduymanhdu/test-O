package com.uth.labodc.user.security;

public record AuthenticatedUser(
        String userId,
        String email,
        String role
) {
}
