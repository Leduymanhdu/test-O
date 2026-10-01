package com.uth.labodc.repository;

import com.uth.labodc.model.entity.ProjectRejection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRejectionRepository extends JpaRepository<ProjectRejection, Long> {
    
    List<ProjectRejection> findByProjectIdOrderByRejectedAtDesc(Long projectId);
    
    List<ProjectRejection> findByRejectedBy(Long rejectedBy);
}
