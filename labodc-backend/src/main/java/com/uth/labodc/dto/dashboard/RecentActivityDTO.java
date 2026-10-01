package com.uth.labodc.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecentActivityDTO {
    private Long id;
    private String type; // 'project', 'payment', 'enterprise', 'report'
    private String title;
    private String description;
    private LocalDateTime timestamp;
    private String status; // 'success', 'warning', 'info', 'error'
}
