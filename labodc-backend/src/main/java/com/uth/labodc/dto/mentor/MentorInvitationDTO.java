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
public class MentorInvitationDTO {
    private String id;
    private String projectName;
    private String groupName;
    private int studentCount;
    private String description;
    private String deadline;
    private List<String> skills;
    private String receivedDate;
    private String priority; // high | medium | low
}
