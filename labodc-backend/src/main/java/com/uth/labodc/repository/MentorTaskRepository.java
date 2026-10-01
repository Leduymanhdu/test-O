package com.uth.labodc.repository;

import com.uth.labodc.model.entity.MentorTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MentorTaskRepository extends JpaRepository<MentorTask, Long> {
    List<MentorTask> findByMentorIdOrderByDueDateAsc(Long mentorId);

    List<MentorTask> findByMentorIdAndProjectIdOrderByDueDateAsc(Long mentorId, Long projectId);

    List<MentorTask> findByProjectIdOrderByDueDateAsc(Long projectId);

    List<MentorTask> findByProjectIdInOrderByDueDateAsc(List<Long> projectIds);
}
