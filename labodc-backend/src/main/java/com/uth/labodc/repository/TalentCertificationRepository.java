package com.uth.labodc.repository;

import com.uth.labodc.model.entity.TalentCertification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TalentCertificationRepository extends JpaRepository<TalentCertification, Long> {
    
    List<TalentCertification> findByTalentId(Long talentId);
    
    List<TalentCertification> findByTalentIdOrderByIssueDateDesc(Long talentId);
    
    @Query("SELECT tc FROM TalentCertification tc WHERE tc.talentId = :talentId AND tc.expiryDate >= :currentDate")
    List<TalentCertification> findValidCertifications(@Param("talentId") Long talentId, @Param("currentDate") LocalDate currentDate);
    
    @Query("SELECT tc FROM TalentCertification tc WHERE tc.talentId = :talentId AND tc.expiryDate < :currentDate")
    List<TalentCertification> findExpiredCertifications(@Param("talentId") Long talentId, @Param("currentDate") LocalDate currentDate);
    
    @Query("SELECT tc FROM TalentCertification tc WHERE tc.expiryDate BETWEEN :startDate AND :endDate")
    List<TalentCertification> findCertificationsExpiringBetween(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    long countByTalentId(Long talentId);
    
    boolean existsByTalentIdAndName(Long talentId, String name);
}