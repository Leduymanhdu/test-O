package com.uth.labodc.dto.enterprise;

import lombok.Data;

@Data
public class CreateEnterpriseFeedbackRequest {
    private Long projectId;
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
}
