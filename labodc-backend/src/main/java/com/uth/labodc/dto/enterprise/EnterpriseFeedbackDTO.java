package com.uth.labodc.dto.enterprise;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnterpriseFeedbackDTO {
    private Long id;
    private Long projectId;
    private String projectName;
    private Double overallRating;
    private Double qualityRating;
    private Double communicationRating;
    private Double timelineRating;
    private Double professionalismRating;
    private String positiveFeedback;
    private String negativeFeedback;
    private String suggestions;
    private Boolean wouldRecommend;
    private Boolean wouldWorkAgain;
    private String status;
    private String submittedAt;
    private String createdAt;
}
