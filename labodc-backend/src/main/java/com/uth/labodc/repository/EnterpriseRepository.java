package com.uth.labodc.repository;

import com.uth.labodc.model.entity.Enterprise;
import com.uth.labodc.model.enums.EnterpriseStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EnterpriseRepository extends JpaRepository<Enterprise, Long> {
    
    boolean existsByTaxCode(String taxCode);
    
    boolean existsByUserId(Long userId);
    
    long countByStatus(EnterpriseStatus status);
    
    @Query("SELECT COUNT(e) FROM Enterprise e WHERE e.createdAt >= :since")
    long countNewEnterprises(LocalDateTime since);
    
    @Query(value = "SELECT COUNT(e.id) FROM enterprises e JOIN users u ON e.user_id = u.id WHERE u.status = 'ACTIVE'", nativeQuery = true)
    long countActiveEnterprises();
    
    @Query(value = "SELECT e.id, e.user_id, e.company_name, e.tax_code, e.business_license_number, e.address, e.city, e.district, e.ward, " +
           "e.representative_name, e.representative_position, e.contact_email, e.contact_phone, e.website, e.industry, e.company_size, " +
           "e.year_established, e.description, e.status, e.verified_at, e.verified_by, e.created_at, e.updated_at, e.deleted_at, " +
           "COUNT(DISTINCT p.id) as total_projects, " +
           "COUNT(DISTINCT CASE WHEN p.status IN ('RECRUITING', 'IN_PROGRESS') THEN p.id END) as active_projects, " +
           "COALESCE(SUM(p.budget), 0) as total_budget " +
           "FROM enterprises e " +
           "LEFT JOIN projects p ON e.id = p.enterprise_id " +
           "GROUP BY e.id, e.user_id, e.company_name, e.tax_code, e.business_license_number, e.address, e.city, e.district, e.ward, " +
           "e.representative_name, e.representative_position, e.contact_email, e.contact_phone, e.website, e.industry, e.company_size, " +
           "e.year_established, e.description, e.status, e.verified_at, e.verified_by, e.created_at, e.updated_at, e.deleted_at " +
           "ORDER BY e.created_at DESC",
           nativeQuery = true)
    List<Object[]> findAllWithProjectStats();
    
    @Query(value = "SELECT e.id, e.user_id, e.company_name, e.tax_code, e.business_license_number, e.address, e.city, e.district, e.ward, " +
           "e.representative_name, e.representative_position, e.contact_email, e.contact_phone, e.website, e.industry, e.company_size, " +
           "e.year_established, e.description, e.status, e.verified_at, e.verified_by, e.created_at, e.updated_at, e.deleted_at, " +
           "COUNT(DISTINCT p.id) as total_projects, " +
           "COUNT(DISTINCT CASE WHEN p.status IN ('RECRUITING', 'IN_PROGRESS') THEN p.id END) as active_projects, " +
           "COALESCE(SUM(p.budget), 0) as total_budget " +
           "FROM enterprises e " +
           "LEFT JOIN projects p ON e.id = p.enterprise_id " +
           "WHERE e.status = CAST(:status AS enterprise_status_enum) " +
           "GROUP BY e.id, e.user_id, e.company_name, e.tax_code, e.business_license_number, e.address, e.city, e.district, e.ward, " +
           "e.representative_name, e.representative_position, e.contact_email, e.contact_phone, e.website, e.industry, e.company_size, " +
           "e.year_established, e.description, e.status, e.verified_at, e.verified_by, e.created_at, e.updated_at, e.deleted_at " +
           "ORDER BY e.created_at DESC",
           nativeQuery = true)
    List<Object[]> findByStatusWithProjectStats(String status);
}

