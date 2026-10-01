package com.uth.labodc.repository;

import com.uth.labodc.model.entity.ProjectMember;
import com.uth.labodc.model.enums.ProjectStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProjectMemberRepository extends JpaRepository<ProjectMember, Long> {
    List<ProjectMember> findByProjectId(Long projectId);
    List<ProjectMember> findByProjectIdAndStatus(Long projectId, ProjectMember.MemberStatus status);
    List<ProjectMember> findByTalentId(Long talentId);
    Optional<ProjectMember> findByProjectIdAndTalentId(Long projectId, Long talentId);
    boolean existsByProjectIdAndTalentId(Long projectId, Long talentId);
    void deleteByProjectId(Long projectId);
    Integer countByProjectId(Long projectId);
    Integer countByProjectIdAndStatus(Long projectId, ProjectMember.MemberStatus status);

    @Query("SELECT COUNT(DISTINCT pm.projectId) FROM ProjectMember pm WHERE pm.talentId = :talentId")
    Integer countDistinctProjectIdByTalentId(Long talentId);

    @Query("SELECT COUNT(DISTINCT pm.projectId) FROM ProjectMember pm JOIN Project p ON p.id = pm.projectId " +
           "WHERE pm.talentId = :talentId AND p.status = :status")
    Integer countDistinctProjectIdByTalentIdAndProjectStatus(Long talentId, ProjectStatus status);
}
