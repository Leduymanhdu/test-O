package com.uth.labodc.project.security;

public record AuthenticatedUser(
        long userId,
        String email,
        String role
) {
}
