package com.uth.labodc.repository;

import com.uth.labodc.model.entity.MentorTaskSubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MentorTaskSubmissionRepository extends JpaRepository<MentorTaskSubmission, Long> {
    List<MentorTaskSubmission> findByTaskIdOrderBySubmittedAtDesc(Long taskId);
}
