package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorReportDTO {
    private String id;
    private String student;
    private String studentId;
    private String reportName;
    private String status; // submitted | pending | late
    private String submittedDate;
    private String dueDate;
    private Double score;
    private String fileSize;
    private String fileName;
}
