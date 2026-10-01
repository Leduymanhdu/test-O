package com.uth.labodc.repository;

import com.uth.labodc.model.entity.TalentEvaluation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TalentEvaluationRepository extends JpaRepository<TalentEvaluation, Long> {

    List<TalentEvaluation> findByMentorIdOrderByCreatedAtDesc(Long mentorId);

    List<TalentEvaluation> findByMentorIdAndProjectIdOrderByCreatedAtDesc(Long mentorId, Long projectId);

    Optional<TalentEvaluation> findByProjectIdAndTalentIdAndEvaluationPeriod(Long projectId, Long talentId, String evaluationPeriod);
}
