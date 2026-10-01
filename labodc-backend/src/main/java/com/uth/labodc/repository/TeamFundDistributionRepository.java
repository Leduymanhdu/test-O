package com.uth.labodc.repository;

import com.uth.labodc.model.entity.TeamFundDistribution;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TeamFundDistributionRepository extends JpaRepository<TeamFundDistribution, Long> {
    
    Optional<TeamFundDistribution> findByProjectId(Long projectId);
    
    List<TeamFundDistribution> findByStatus(String status);
    
    List<TeamFundDistribution> findBySubmittedBy(Long submittedBy);
    
    List<TeamFundDistribution> findByAllocationId(Long allocationId);
}
