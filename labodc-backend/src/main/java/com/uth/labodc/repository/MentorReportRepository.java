package com.uth.labodc.repository;

import com.uth.labodc.model.entity.MentorReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MentorReportRepository extends JpaRepository<MentorReport, Long> {
    List<MentorReport> findByMentorIdOrderByDueDateDesc(Long mentorId);
}
