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
public class MentorDashboardDTO {
    private List<MentorStatCardDTO> stats;
    private List<MentorQuickActionDTO> quickActions;
    private List<MentorActivityDTO> recentActivities;
}
