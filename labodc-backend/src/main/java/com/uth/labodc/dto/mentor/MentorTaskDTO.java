package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MentorTaskDTO {
    private String id;
    private Long projectId;
    private String title;
    private String description;
    private String status; // completed | in-progress | pending
    private int progress;
    private List<String> assignedTo;
    private String dueDate;
    private String priority; // high | medium | low
    private String projectName;
}
