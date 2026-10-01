package com.uth.labodc.repository;

import com.uth.labodc.model.entity.FundAllocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FundAllocationRepository extends JpaRepository<FundAllocation, Long> {
    
    Optional<FundAllocation> findByProjectId(Long projectId);
    
    List<FundAllocation> findByStatus(String status);
    
    List<FundAllocation> findByPaymentId(Long paymentId);
}
