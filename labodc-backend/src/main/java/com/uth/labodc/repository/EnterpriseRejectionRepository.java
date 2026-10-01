package com.uth.labodc.repository;

import com.uth.labodc.model.entity.EnterpriseRejection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EnterpriseRejectionRepository extends JpaRepository<EnterpriseRejection, Long> {
    
    List<EnterpriseRejection> findByEnterpriseIdOrderByRejectedAtDesc(Long enterpriseId);
    
    List<EnterpriseRejection> findByRejectedBy(Long rejectedBy);
}
