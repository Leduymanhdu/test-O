package com.uth.labodc.dto.talent;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TalentTaskSubmissionDTO {
    private Long id;
    private Long taskId;
    private String fileName;
    private Long fileSize;
    private String submittedAt;
}
