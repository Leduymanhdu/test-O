package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MentorTaskUpsertRequest {
    private String title;
    private String description;
    private String status; // pending | in-progress | completed
    private Integer progress; // 0..100
    private List<String> assignedTo;
    private String dueDate; // ISO string or YYYY-MM-DD
    private String priority; // low | medium | high
}
