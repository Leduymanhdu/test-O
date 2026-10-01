package com.uth.labodc.dto.talent;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TalentTaskDTO {
    private Long id;
    private Long projectId;
    private String title;
    private String description;
    private String status;
    private Integer progress;
    private LocalDate dueDate;
    private String priority;
    private String projectName;
    private List<String> assignedTo;
}
