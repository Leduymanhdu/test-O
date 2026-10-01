package com.uth.labodc.dto.mentor;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectTaskDTO {
    private Long id;
    private Long projectId;
    private String taskId;
    private String taskName;
    private String description;
    private Long assignedTo;
    private String assignedToName;
    private String priority;
    private LocalDate startDate;
    private LocalDate dueDate;
    private Integer estimatedHours;
    private Integer actualHours;
    private String status;
    private String dependencies;
    private String tags;
}
