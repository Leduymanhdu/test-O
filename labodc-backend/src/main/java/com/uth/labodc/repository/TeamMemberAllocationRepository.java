package com.uth.labodc.repository;

import com.uth.labodc.model.entity.TeamMemberAllocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TeamMemberAllocationRepository extends JpaRepository<TeamMemberAllocation, Long> {
    List<TeamMemberAllocation> findByDistributionId(Long distributionId);
    void deleteByDistributionId(Long distributionId);
}
