package com.uth.labodc.dto.talent;

import com.uth.labodc.model.enums.UserRole;
import com.uth.labodc.model.enums.UserStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class TalentProfileResponse {
    private Long id;
    private String email;
    private UserRole role;
    private UserStatus status;
    private Boolean emailVerified;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;
}
