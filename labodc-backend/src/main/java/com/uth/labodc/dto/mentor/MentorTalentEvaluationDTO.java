package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorTalentEvaluationDTO {
    private Long id;
    private Long projectId;
    private Long talentId;
    private String fullName;
    private String studentId;

    private String evaluationPeriod; // YYYY-MM
    private Double overallScore; // 0-10
    private String grade; // A|B|C|D|F

    private Map<String, Object> technicalSkills;
    private Map<String, Object> problemSolving;
    private Map<String, Object> teamwork;
    private Map<String, Object> communication;
    private Map<String, Object> codeQuality;
    private Map<String, Object> punctuality;

    private List<String> strengths;
    private List<String> weaknesses;
    private List<String> recommendations;

    private Integer tasksCompleted;
    private Integer tasksTotal;
    private Integer hoursWorked;

    private LocalDateTime createdAt;
}
