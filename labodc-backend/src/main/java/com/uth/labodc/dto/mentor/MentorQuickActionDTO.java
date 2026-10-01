package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorQuickActionDTO {
    private String id;
    private String title;
    private String description;
    private String variant; // primary | success | ghost
}
