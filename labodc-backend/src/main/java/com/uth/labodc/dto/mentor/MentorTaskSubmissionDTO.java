package com.uth.labodc.dto.mentor;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MentorTaskSubmissionDTO {
    private Long id;
    private Long taskId;
    private Long talentId;
    private String talentName;
    private String studentId;
    private String fileName;
    private Long fileSize;
    private String submittedAt;
}
