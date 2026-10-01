package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorProjectDTO {
    private String id;
    private String title;
    private String status;
    private int progress;
    private String startDate;
    private String endDate;
    private Integer studentCount;
}
