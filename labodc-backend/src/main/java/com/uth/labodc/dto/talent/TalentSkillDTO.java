package com.uth.labodc.dto.talent;

import com.uth.labodc.model.entity.TalentSkill.SkillLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TalentSkillDTO {
    private Long id;
    private String skillName;
    private String skillCategory;
    private SkillLevel proficiencyLevel;
    private Double yearsOfExperience;
    
    // Helper getters for frontend
    public String getLevel() {
        return proficiencyLevel != null ? proficiencyLevel.name() : null;
    }
}