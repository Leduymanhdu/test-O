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
public class CreateTaskRequest {
    private Long projectId;
    private String taskId;
    private String taskName;
    private String description;
    private Long assignedTo;
    private String priority; // LOW, MEDIUM, HIGH, CRITICAL
    private String startDate; // YYYY-MM-DD
    private String dueDate;
    private Integer estimatedHours;
    private String dependencies;
    private String tags;
}
