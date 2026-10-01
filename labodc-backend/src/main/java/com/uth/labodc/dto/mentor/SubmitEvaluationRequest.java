package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubmitEvaluationRequest {
    private Long talentId;
    private String evaluationPeriod; // YYYY-MM
    private Double overallScore;
    private Map<String, Object> technicalSkills; // {score, comment}
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
}
