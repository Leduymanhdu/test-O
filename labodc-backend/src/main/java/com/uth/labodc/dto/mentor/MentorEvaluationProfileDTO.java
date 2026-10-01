package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorEvaluationProfileDTO {
    private String id;
    private String name;
    private String status; // excellent | good | average
    private String statusText;
    private int technicalSkills;
    private int progress;
    private int attendance;
    private int teamwork;
    private String avatar;
    private String notes;
}
