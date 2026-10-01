package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorStatCardDTO {
    private String id;
    private String title;
    private Object value;
    private String color;
    private MentorTrendDTO trend;
}
