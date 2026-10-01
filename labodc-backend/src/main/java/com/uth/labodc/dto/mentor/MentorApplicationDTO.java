package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorApplicationDTO {
    private Long memberId;
    private Long projectId;
    private Long talentId;
    private String fullName;
    private String studentId;
    private String email;
    private String status; // PENDING, ACTIVE, REJECTED
    private String joinMessage;
    private LocalDateTime createdAt;
    private List<String> skills;
}
