package com.uth.labodc.repository;

import com.uth.labodc.model.entity.TalentSkill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TalentSkillRepository extends JpaRepository<TalentSkill, Long> {
    
    List<TalentSkill> findByTalentId(Long talentId);
    
    List<TalentSkill> findByTalentIdOrderByCreatedAtDesc(Long talentId);
    
    Optional<TalentSkill> findByTalentIdAndSkillName(Long talentId, String skillName);
    
    @Query("SELECT ts FROM TalentSkill ts WHERE ts.talentId = :talentId AND ts.skillCategory = :category")
    List<TalentSkill> findByTalentIdAndSkillCategory(@Param("talentId") Long talentId, @Param("category") String category);
    
    @Query("SELECT DISTINCT ts.skillName FROM TalentSkill ts WHERE LOWER(ts.skillName) LIKE LOWER(CONCAT('%', :skillName, '%'))")
    List<String> findSkillNamesSuggestions(@Param("skillName") String skillName);
    
    void deleteByTalentIdAndSkillName(Long talentId, String skillName);

    void deleteByTalentId(Long talentId);
    
    long countByTalentId(Long talentId);
}
