package com.uth.labodc.service;

import com.uth.labodc.dto.enterprise.EnterpriseListDTO;
import com.uth.labodc.dto.enterprise.EnterpriseStatsDTO;
import com.uth.labodc.model.entity.Enterprise;
import com.uth.labodc.model.enums.EnterpriseStatus;
import com.uth.labodc.repository.EnterpriseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class EnterpriseManagementService {
    
    private final EnterpriseRepository enterpriseRepository;
    
    @Transactional(readOnly = true)
    public EnterpriseStatsDTO getEnterpriseStats() {
        long total = enterpriseRepository.count();
        long approved = enterpriseRepository.countByStatus(EnterpriseStatus.APPROVED);
        long pending = enterpriseRepository.countByStatus(EnterpriseStatus.PENDING);
        long rejected = enterpriseRepository.countByStatus(EnterpriseStatus.REJECTED);
        long active = enterpriseRepository.countActiveEnterprises();
        
        LocalDateTime thisMonthStart = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        long thisMonth = enterpriseRepository.countNewEnterprises(thisMonthStart);
        
        return EnterpriseStatsDTO.builder()
                .total(total)
                .verified(approved)
                .unverified(pending + rejected)
                .active(active)
                .thisMonth(thisMonth)
                .build();
    }
    
    @Transactional(readOnly = true)
    public List<EnterpriseListDTO> getAllEnterprisesWithStats(EnterpriseStatus statusFilter, String searchText) {
        log.info("Fetching enterprises with stats, statusFilter: {}, searchText: {}", statusFilter, searchText);
        
        // Get all enterprises with project stats
        List<Object[]> results = enterpriseRepository.findAllWithProjectStats();
        
        List<EnterpriseListDTO> enterprises = new ArrayList<>();
        for (Object[] row : results) {
            Enterprise e = mapToEnterprise(row);
            
            // Apply status filter if provided
            if (statusFilter != null && !statusFilter.equals(e.getStatus())) {
                continue;
            }
            
            // Apply search filter if provided
            if (searchText != null && !searchText.trim().isEmpty()) {
                String search = searchText.toLowerCase().trim();
                boolean matches = (e.getCompanyName() != null && e.getCompanyName().toLowerCase().contains(search)) ||
                                 (e.getTaxCode() != null && e.getTaxCode().toLowerCase().contains(search)) ||
                                 (e.getContactEmail() != null && e.getContactEmail().toLowerCase().contains(search));
                if (!matches) {
                    continue;
                }
            }
            
            // Extract aggregated data (columns after enterprise fields)
            // Enterprise has 24 columns (id through deleted_at)
            // Handle aggregated columns safely - they come after all enterprise columns
            int lastEnterpriseColIndex = 23; // 0-based index of last enterprise column (deleted_at)
            int totalProjects = 0;
            int activeProjects = 0;
            long totalBudget = 0L;
            
            // Safely extract aggregated data
            if (row.length > lastEnterpriseColIndex + 1 && row[lastEnterpriseColIndex + 1] != null) {
                Object totalProjectsObj = row[lastEnterpriseColIndex + 1];
                if (totalProjectsObj instanceof Number) {
                    totalProjects = ((Number) totalProjectsObj).intValue();
                }
            }
            if (row.length > lastEnterpriseColIndex + 2 && row[lastEnterpriseColIndex + 2] != null) {
                Object activeProjectsObj = row[lastEnterpriseColIndex + 2];
                if (activeProjectsObj instanceof Number) {
                    activeProjects = ((Number) activeProjectsObj).intValue();
                }
            }
            if (row.length > lastEnterpriseColIndex + 3 && row[lastEnterpriseColIndex + 3] != null) {
                Object totalBudgetObj = row[lastEnterpriseColIndex + 3];
                if (totalBudgetObj instanceof Number) {
                    totalBudget = ((Number) totalBudgetObj).longValue();
                }
            }
            
            log.debug("Building DTO for enterprise ID={}, status from entity: {}", e.getId(), e.getStatus());
            
            EnterpriseListDTO dto = EnterpriseListDTO.builder()
                    .id(e.getId())
                    .userId(e.getUserId())
                    .companyName(e.getCompanyName())
                    .taxCode(e.getTaxCode())
                    .contactEmail(e.getContactEmail())
                    .contactPhone(e.getContactPhone())
                    .industry(e.getIndustry())
                    .companySize(e.getCompanySize())
                    .status(e.getStatus())
                    .verifiedAt(e.getVerifiedAt())
                    .createdAt(e.getCreatedAt())
                    .totalProjects(totalProjects)
                    .activeProjects(activeProjects)
                    .totalBudget(totalBudget)
                    .build();
            
            log.debug("DTO built with status: {}", dto.getStatus());
            enterprises.add(dto);
        }
        
        log.info("Found {} enterprises", enterprises.size());
        return enterprises;
    }
    
    private Enterprise mapToEnterprise(Object[] row) {
        // Debug: Log all row values
        log.debug("Row length: {}, Row values:", row.length);
        for (int i = 0; i < Math.min(row.length, 25); i++) {
            log.debug("  row[{}] = {} ({})", i, row[i], row[i] != null ? row[i].getClass().getSimpleName() : "null");
        }
        
        Enterprise e = new Enterprise();
        e.setId(((Number) row[0]).longValue());
        e.setUserId(row[1] != null ? ((Number) row[1]).longValue() : null);
        e.setCompanyName((String) row[2]);
        e.setTaxCode((String) row[3]);
        e.setBusinessLicenseNumber((String) row[4]);
        e.setAddress((String) row[5]);
        e.setCity((String) row[6]);
        e.setDistrict((String) row[7]);
        e.setWard((String) row[8]);
        e.setRepresentativeName((String) row[9]);
        e.setRepresentativePosition((String) row[10]);
        e.setContactEmail((String) row[11]);
        e.setContactPhone((String) row[12]);
        e.setWebsite((String) row[13]);
        e.setIndustry((String) row[14]);
        e.setCompanySize((String) row[15]);
        e.setYearEstablished(row[16] != null ? ((Number) row[16]).intValue() : null);
        e.setDescription((String) row[17]);
        
        // Handle status - PostgreSQL enum comes as String
        if (row[18] != null) {
            String statusStr = row[18].toString();
            log.debug("Raw status from DB: '{}' (type: {})", statusStr, row[18].getClass().getName());
            try {
                e.setStatus(EnterpriseStatus.valueOf(statusStr.toUpperCase()));
                log.debug("Parsed status: {}", e.getStatus());
            } catch (IllegalArgumentException ex) {
                log.warn("Invalid status value '{}' for enterprise at row[0]={}, defaulting to PENDING", statusStr, row[0]);
                e.setStatus(EnterpriseStatus.PENDING);
            }
        } else {
            log.warn("Status is null for enterprise at row[0]={}, defaulting to PENDING", row[0]);
            e.setStatus(EnterpriseStatus.PENDING);
        }
        
        // Handle verifiedAt - can be Timestamp or Long (epoch millis)
        if (row[19] != null) {
            if (row[19] instanceof Timestamp) {
                e.setVerifiedAt(((Timestamp) row[19]).toLocalDateTime());
            } else if (row[19] instanceof Long) {
                e.setVerifiedAt(new Timestamp((Long) row[19]).toLocalDateTime());
            }
        }
        
        // Handle verifiedBy
        if (row[20] != null) {
            if (row[20] instanceof Number) {
                e.setVerifiedBy(((Number) row[20]).longValue());
            }
        }
        
        // Handle createdAt
        if (row[21] != null) {
            if (row[21] instanceof Timestamp) {
                e.setCreatedAt(((Timestamp) row[21]).toLocalDateTime());
            } else if (row[21] instanceof Long) {
                e.setCreatedAt(new Timestamp((Long) row[21]).toLocalDateTime());
            }
        }
        
        // Handle updatedAt
        if (row[22] != null) {
            if (row[22] instanceof Timestamp) {
                e.setUpdatedAt(((Timestamp) row[22]).toLocalDateTime());
            } else if (row[22] instanceof Long) {
                e.setUpdatedAt(new Timestamp((Long) row[22]).toLocalDateTime());
            }
        }
        
        // row[23] is deletedAt, skip it
        // row[24], row[25], row[26] are total_projects, active_projects, total_budget
        return e;
    }
}
