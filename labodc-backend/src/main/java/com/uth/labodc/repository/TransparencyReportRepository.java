package com.uth.labodc.repository;

import com.uth.labodc.model.entity.TransparencyReport;
import com.uth.labodc.model.enums.ReportStatus;
import com.uth.labodc.model.enums.ReportType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransparencyReportRepository extends JpaRepository<TransparencyReport, Long> {
    
    /**
     * Find all reports by status
     */
    List<TransparencyReport> findByStatusOrderByCreatedAtDesc(ReportStatus status);
    
    /**
     * Find all reports ordered by created date descending
     */
    List<TransparencyReport> findAllByOrderByCreatedAtDesc();
    
    /**
     * Find report by period
     */
    Optional<TransparencyReport> findByPeriod(String period);
    
    /**
     * Find reports by type
     */
    List<TransparencyReport> findByReportTypeOrderByCreatedAtDesc(ReportType reportType);
    
    /**
     * Find reports by type and status
     */
    List<TransparencyReport> findByReportTypeAndStatusOrderByCreatedAtDesc(
            ReportType reportType, ReportStatus status);
    
    /**
     * Find published reports
     */
    @Query("SELECT r FROM TransparencyReport r WHERE r.status = 'PUBLISHED' ORDER BY r.publishedAt DESC")
    List<TransparencyReport> findPublishedReports();
    
    /**
     * Check if report exists for period
     */
    boolean existsByPeriod(String period);
    
    /**
     * Count reports by status
     */
    long countByStatus(ReportStatus status);
}
