package com.uth.labodc.repository;

import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.enums.ProjectStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {
    
    long countByStatus(ProjectStatus status);
    
    @Query("SELECT COUNT(p) FROM Project p WHERE p.createdAt >= :since")
    long countNewProjects(LocalDateTime since);
    
    @Query("SELECT p FROM Project p ORDER BY p.createdAt DESC")
    List<Project> findRecentProjects(Pageable pageable);
    
    @Query("SELECT COUNT(p) FROM Project p WHERE p.status = 'COMPLETED'")
    long countCompletedProjects();
    
    @Query("SELECT p FROM Project p WHERE p.validated = 'pending' ORDER BY p.createdAt DESC")
    List<Project> findPendingValidation(Pageable pageable);
    
    @Query("SELECT COALESCE(SUM(p.budget), 0) FROM Project p WHERE p.status = 'COMPLETED'")
    Long getTotalCompletedBudget();
    
    @Query("SELECT COALESCE(SUM(p.budget), 0) FROM Project p WHERE p.status = 'IN_PROGRESS'")
    Long getTotalInProgressBudget();
    
    @Query("SELECT COALESCE(SUM(p.budget), 0) FROM Project p")
    Long getTotalBudget();
    
    @Query(value = "SELECT " +
           "TO_CHAR(p.created_at, 'MM/YYYY') as month, " +
           "COALESCE(SUM(CASE WHEN p.status = 'COMPLETED' THEN p.budget ELSE 0 END), 0) as revenue " +
           "FROM projects p " +
           "WHERE p.created_at >= NOW() - CAST(:months || ' MONTH' AS INTERVAL) " +
           "GROUP BY TO_CHAR(p.created_at, 'MM/YYYY'), DATE_TRUNC('month', p.created_at) " +
           "ORDER BY DATE_TRUNC('month', p.created_at) ASC", 
           nativeQuery = true)
    List<Object[]> getMonthlyRevenue(int months);
    
    // Additional methods for validation
    long countByValidated(String validated);
    
    long countByCreatedAtAfter(LocalDateTime dateTime);

    List<Project> findByStatus(ProjectStatus status);

    List<Project> findByStatusAndAllowApplicationsTrueAndIsPublicTrue(ProjectStatus status);

    List<Project> findByValidatedAndStatusNot(String validated, ProjectStatus status);
    
    // Management query with ALL columns + technologies array + rejection data
    @Query(value = "SELECT p.id, p.enterprise_id, p.mentor_id, p.title, p.slug, p.description, " +
           "p.objectives, p.requirements, p.start_date, p.end_date, p.actual_start_date, p.actual_end_date, " +
           "p.budget, p.currency, p.number_of_students, p.current_members_count, p.status, p.progress_percentage, " +
           "p.validated, p.validated_at, p.validated_by, p.validation_note, p.rejection_reason, " +
           "p.is_public, p.allow_applications, p.created_at, p.updated_at, p.published_at, p.deleted_at, " +
           "COALESCE(array_agg(DISTINCT pt.technology_name) FILTER (WHERE pt.technology_name IS NOT NULL), '{}') as technologies, " +
           "pr.rejection_reason as pr_rejection_reason, pr.rejected_at as pr_rejected_at, pr.rejected_by as pr_rejected_by " +
           "FROM projects p " +
           "LEFT JOIN project_technologies pt ON p.id = pt.project_id " +
           "LEFT JOIN project_rejections pr ON p.id = pr.project_id " +
           "GROUP BY p.id, pr.id " +
           "ORDER BY p.created_at DESC",
           nativeQuery = true)
    List<Object[]> findAllWithStats();
    
    // LAB ADMIN CRUD methods
    Integer countByEnterpriseId(Long enterpriseId);
    Integer countByEnterpriseIdAndStatus(Long enterpriseId, ProjectStatus status);
    Integer countByMentorId(Long mentorId);

    List<Project> findByMentorId(Long mentorId);
}
