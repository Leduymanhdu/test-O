package com.uth.labodc.dto.auth;

import com.uth.labodc.model.enums.UserRole;
import com.uth.labodc.model.enums.UserStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String refreshToken;
    @Builder.Default
    private String tokenType = "Bearer";
    private Long userId;
    private String email;
    private UserRole role;
    private UserStatus status;
    private Boolean emailVerified;
}
