package com.uth.labodc.service;

import com.uth.labodc.dto.project.ProjectListDTO;
import com.uth.labodc.dto.project.ProjectStatsDTO;
import com.uth.labodc.model.entity.Project;
import com.uth.labodc.model.entity.ProjectRejection;
import com.uth.labodc.model.entity.ProjectMember;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.ProjectMemberRepository;
import com.uth.labodc.repository.ProjectRepository;
import com.uth.labodc.repository.ProjectRejectionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Propagation;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectManagementService {
    
    private final ProjectRepository projectRepository;
    private final ProjectRejectionRepository projectRejectionRepository;
    private final ProjectMemberRepository projectMemberRepository;
    
    @Transactional(readOnly = true)
    public ProjectStatsDTO getProjectStats() {
        long total = projectRepository.count();
        long pending = projectRepository.countByValidated("pending");
        long validated = projectRepository.countByValidated("approved");
        long rejected = projectRepository.countByValidated("rejected");
        long recruiting = projectRepository.countByStatus(ProjectStatus.RECRUITING);
        long inProgress = projectRepository.countByStatus(ProjectStatus.IN_PROGRESS);
        long completed = projectRepository.countByStatus(ProjectStatus.COMPLETED);
        
        return ProjectStatsDTO.builder()
                .total(total)
                .pending(pending)
                .validated(validated)
                .recruiting(recruiting)
                .inProgress(inProgress)
                .completed(completed)
                .build();
    }
    
    @Transactional(readOnly = true, propagation = Propagation.NOT_SUPPORTED)
    public List<ProjectListDTO> getAllProjectsWithStats(String validatedFilter, String searchText) {
        log.info("Fetching projects with stats, validatedFilter: {}, searchText: {}", validatedFilter, searchText);
        
        try {
            // Get all projects with team and application stats
            List<Object[]> results = projectRepository.findAllWithStats();
            log.info("Query returned {} results", results.size());
            
            List<ProjectListDTO> projects = new ArrayList<>();
            for (Object[] row : results) {
                try {
                    Project p = mapToProject(row);
                    
                    // Apply validated filter if provided
                    if (validatedFilter != null && !validatedFilter.equals(p.getValidated())) {
                        continue;
                    }
                    
                    // Apply search filter if provided
                    if (searchText != null && !searchText.trim().isEmpty()) {
                        String search = searchText.toLowerCase();
                        boolean matches = (p.getTitle() != null && p.getTitle().toLowerCase().contains(search)) ||
                                        (p.getDescription() != null && p.getDescription().toLowerCase().contains(search));
                        if (!matches) {
                            continue;
                        }
                    }
                    
                    int totalTeamMembers = safeCountMembers(p.getId());
                    int totalApplications = safeCountApplications(p.getId());
                    
                    ProjectListDTO dto = ProjectListDTO.builder()
                            .id(p.getId())
                            .enterpriseId(p.getEnterpriseId())
                            .title(p.getTitle())
                            .description(p.getDescription())
                            .status(p.getStatus())
                            .validated(p.getValidated())
                            .validatedAt(p.getValidatedAt())
                            .budget(p.getBudget())
                            .numberOfStudents(p.getNumberOfStudents())
                            .currentMembersCount(p.getCurrentMembersCount())
                            .progressPercentage(p.getProgressPercentage())
                            .startDate(p.getStartDate())
                            .endDate(p.getEndDate())
                            .createdAt(p.getCreatedAt())
                            .totalTeamMembers(totalTeamMembers)
                            .totalApplications(totalApplications)
                            .technologies(p.getTechnologies())
                            .build();
                    
                    log.debug("Mapped project: id={}, title={}, validated={}, status={}", 
                            dto.getId(), dto.getTitle(), dto.getValidated(), dto.getStatus());
                    
                    projects.add(dto);
                } catch (Exception e) {
                    log.error("Error mapping project row: {}", e.getMessage(), e);
                    // Continue with next row
                }
            }
            
            log.info("Found {} projects after filtering", projects.size());
            return projects;
        } catch (Exception e) {
            log.error("Error fetching projects with stats, falling back to basic query: {}", e.getMessage(), e);
            try {
                return fallbackProjects(validatedFilter, searchText);
            } catch (Exception fallbackError) {
                log.error("Fallback query failed for projects: {}", fallbackError.getMessage(), fallbackError);
                return new ArrayList<>();
            }
        }
    }
    
    private int getLastProjectColumnIndex() {
        // Project table has ALL these columns (32 total, 0-based index 0-31):
        // 0: id, 1: enterprise_id, 2: mentor_id, 3: title, 4: slug, 5: description,
        // 6: objectives, 7: requirements, 8: start_date, 9: end_date, 10: actual_start_date, 11: actual_end_date,
        // 12: budget, 13: currency, 14: number_of_students, 15: current_members_count, 16: status, 17: progress_percentage,
        // 18: validated, 19: validated_at, 20: validated_by, 21: validation_note, 22: rejection_reason,
        // 23: is_public, 24: allow_applications, 25: created_at, 26: updated_at, 27: published_at, 28: deleted_at,
        // 29: technologies (array), 30: pr_rejection_reason, 31: pr_rejected_at, 32: pr_rejected_by
        return 31; // 0-based index of last column
    }

    private int safeCountMembers(Long projectId) {
        try {
            Integer approved = projectMemberRepository.countByProjectIdAndStatus(
                    projectId, ProjectMember.MemberStatus.APPROVED);
            Integer active = projectMemberRepository.countByProjectIdAndStatus(
                    projectId, ProjectMember.MemberStatus.ACTIVE);
            return (approved != null ? approved : 0) + (active != null ? active : 0);
        } catch (Exception e) {
            log.warn("Failed to count team members for project {}: {}", projectId, e.getMessage());
            return 0;
        }
    }

    private int safeCountApplications(Long projectId) {
        try {
            Integer pending = projectMemberRepository.countByProjectIdAndStatus(
                    projectId, ProjectMember.MemberStatus.PENDING);
            return pending != null ? pending : 0;
        } catch (Exception e) {
            log.warn("Failed to count applications for project {}: {}", projectId, e.getMessage());
            return 0;
        }
    }

    private List<ProjectListDTO> fallbackProjects(String validatedFilter, String searchText) {
        List<Project> projects = projectRepository.findAll();
        List<ProjectListDTO> result = new ArrayList<>();

        for (Project p : projects) {
            if (validatedFilter != null && !validatedFilter.equals(p.getValidated())) {
                continue;
            }
            if (searchText != null && !searchText.trim().isEmpty()) {
                String search = searchText.toLowerCase();
                boolean matches = (p.getTitle() != null && p.getTitle().toLowerCase().contains(search)) ||
                        (p.getDescription() != null && p.getDescription().toLowerCase().contains(search));
                if (!matches) {
                    continue;
                }
            }

            int totalTeamMembers = safeCountMembers(p.getId());
            int totalApplications = safeCountApplications(p.getId());

            ProjectListDTO dto = ProjectListDTO.builder()
                    .id(p.getId())
                    .enterpriseId(p.getEnterpriseId())
                    .title(p.getTitle())
                    .description(p.getDescription())
                    .status(p.getStatus())
                    .validated(p.getValidated())
                    .validatedAt(p.getValidatedAt())
                    .budget(p.getBudget())
                    .numberOfStudents(p.getNumberOfStudents())
                    .currentMembersCount(p.getCurrentMembersCount())
                    .progressPercentage(p.getProgressPercentage())
                    .startDate(p.getStartDate())
                    .endDate(p.getEndDate())
                    .createdAt(p.getCreatedAt())
                    .totalTeamMembers(totalTeamMembers)
                    .totalApplications(totalApplications)
                    .technologies(new ArrayList<>())
                    .build();
            result.add(dto);
        }

        log.info("Fallback query returned {} projects after filtering", result.size());
        return result;
    }
    
    private Project mapToProject(Object[] row) {
        // Debug: Log all row values
        log.debug("Row length: {}, Row values:", row.length);
        for (int i = 0; i < Math.min(row.length, 30); i++) {
            log.debug("  row[{}] = {} ({})", i, row[i], row[i] != null ? row[i].getClass().getSimpleName() : "null");
        }
        
        Project p = new Project();
        p.setId(row[0] != null ? ((Number) row[0]).longValue() : null);
        p.setEnterpriseId(row[1] != null ? ((Number) row[1]).longValue() : null);
        p.setMentorId(row[2] != null ? ((Number) row[2]).longValue() : null);
        p.setTitle((String) row[3]);
        p.setSlug((String) row[4]);
        p.setDescription((String) row[5]);
        p.setObjectives((String) row[6]);
        p.setRequirements((String) row[7]);
        
        // Handle dates - start_date, end_date, actual_start_date, actual_end_date
        if (row[8] != null) {
            if (row[8] instanceof LocalDate) {
                p.setStartDate((LocalDate) row[8]);
            } else if (row[8] instanceof java.sql.Date) {
                p.setStartDate(((java.sql.Date) row[8]).toLocalDate());
            }
        }
        if (row[9] != null) {
            if (row[9] instanceof LocalDate) {
                p.setEndDate((LocalDate) row[9]);
            } else if (row[9] instanceof java.sql.Date) {
                p.setEndDate(((java.sql.Date) row[9]).toLocalDate());
            }
        }
        if (row[10] != null) {
            if (row[10] instanceof LocalDate) {
                p.setActualStartDate((LocalDate) row[10]);
            } else if (row[10] instanceof java.sql.Date) {
                p.setActualStartDate(((java.sql.Date) row[10]).toLocalDate());
            }
        }
        if (row[11] != null) {
            if (row[11] instanceof LocalDate) {
                p.setActualEndDate((LocalDate) row[11]);
            } else if (row[11] instanceof java.sql.Date) {
                p.setActualEndDate(((java.sql.Date) row[11]).toLocalDate());
            }
        }
        
        p.setBudget(row[12] != null ? ((Number) row[12]).longValue() : null);
        p.setCurrency((String) row[13]);
        p.setNumberOfStudents(row[14] != null ? ((Number) row[14]).intValue() : null);
        p.setCurrentMembersCount(row[15] != null ? ((Number) row[15]).intValue() : 0);
        
        // Handle status - PostgreSQL enum comes as String
        if (row[16] != null) {
            String statusStr = row[16].toString();
            log.debug("Raw status from DB: '{}' (type: {})", statusStr, row[16].getClass().getSimpleName());
            try {
                p.setStatus(ProjectStatus.valueOf(statusStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                log.error("Invalid project status: '{}', defaulting to DRAFT", statusStr);
                p.setStatus(ProjectStatus.DRAFT);
            }
        } else {
            log.warn("Status is null for project at row[0]={}, defaulting to DRAFT", row[0]);
            p.setStatus(ProjectStatus.DRAFT);
        }
        
        p.setProgressPercentage(row[17] != null ? ((Number) row[17]).intValue() : 0);
        
        // Handle validated - now String (pending, approved, rejected)
        p.setValidated(row[18] != null ? row[18].toString() : "pending");
        
        // Handle validated_at timestamp
        if (row[19] != null) {
            if (row[19] instanceof Timestamp) {
                p.setValidatedAt(((Timestamp) row[19]).toLocalDateTime());
            } else if (row[19] instanceof LocalDateTime) {
                p.setValidatedAt((LocalDateTime) row[19]);
            } else if (row[19] instanceof Long) {
                p.setValidatedAt(new Timestamp((Long) row[19]).toLocalDateTime());
            }
        }
        
        // Handle validated_by
        p.setValidatedBy(row[20] != null ? ((Number) row[20]).longValue() : null);
        
        // Validation note and rejection reason (from main table, but we load from rejection table too)
        p.setValidationNote((String) row[21]);
        p.setRejectionReason((String) row[22]);
        
        // Handle boolean fields is_public and allow_applications
        if (row[23] != null) {
            if (row[23] instanceof Boolean) {
                p.setIsPublic((Boolean) row[23]);
            } else if (row[23] instanceof Number) {
                p.setIsPublic(((Number) row[23]).intValue() != 0);
            }
        } else {
            p.setIsPublic(true);
        }
        
        if (row[24] != null) {
            if (row[24] instanceof Boolean) {
                p.setAllowApplications((Boolean) row[24]);
            } else if (row[24] instanceof Number) {
                p.setAllowApplications(((Number) row[24]).intValue() != 0);
            }
        } else {
            p.setAllowApplications(true);
        }
        
        // Handle timestamps for created_at, updated_at, published_at, deleted_at
        if (row[25] != null) {
            if (row[25] instanceof Timestamp) {
                p.setCreatedAt(((Timestamp) row[25]).toLocalDateTime());
            } else if (row[25] instanceof LocalDateTime) {
                p.setCreatedAt((LocalDateTime) row[25]);
            } else if (row[25] instanceof Long) {
                p.setCreatedAt(new Timestamp((Long) row[25]).toLocalDateTime());
            }
        }
        
        if (row[26] != null) {
            if (row[26] instanceof Timestamp) {
                p.setUpdatedAt(((Timestamp) row[26]).toLocalDateTime());
            } else if (row[26] instanceof LocalDateTime) {
                p.setUpdatedAt((LocalDateTime) row[26]);
            } else if (row[26] instanceof Long) {
                p.setUpdatedAt(new Timestamp((Long) row[26]).toLocalDateTime());
            }
        }
        
        if (row[27] != null) {
            if (row[27] instanceof Timestamp) {
                p.setPublishedAt(((Timestamp) row[27]).toLocalDateTime());
            } else if (row[27] instanceof LocalDateTime) {
                p.setPublishedAt((LocalDateTime) row[27]);
            } else if (row[27] instanceof Long) {
                p.setPublishedAt(new Timestamp((Long) row[27]).toLocalDateTime());
            }
        }
        
        if (row[28] != null) {
            if (row[28] instanceof Timestamp) {
                p.setDeletedAt(((Timestamp) row[28]).toLocalDateTime());
            } else if (row[28] instanceof LocalDateTime) {
                p.setDeletedAt((LocalDateTime) row[28]);
            } else if (row[28] instanceof Long) {
                p.setDeletedAt(new Timestamp((Long) row[28]).toLocalDateTime());
            }
        }
        
        // Handle technologies array from PostgreSQL (row[29])
        if (row.length > 29 && row[29] != null) {
            if (row[29] instanceof java.sql.Array) {
                try {
                    Object[] techArray = (Object[]) ((java.sql.Array) row[29]).getArray();
                    List<String> technologies = new ArrayList<>();
                    for (Object tech : techArray) {
                        if (tech != null) {
                            technologies.add(tech.toString());
                        }
                    }
                    p.setTechnologies(technologies);
                } catch (Exception e) {
                    log.warn("Error parsing technologies array: {}", e.getMessage());
                    p.setTechnologies(new ArrayList<>());
                }
            } else {
                p.setTechnologies(new ArrayList<>());
            }
        } else {
            p.setTechnologies(new ArrayList<>());
        }
        
        // Handle rejection data from project_rejections table (overrides main table if exists)
        if (row.length > 30 && row[30] != null) {
            p.setRejectionReason((String) row[30]);
            
            if (row[31] != null) {
                if (row[31] instanceof Timestamp) {
                    p.setRejectedAt(((Timestamp) row[31]).toLocalDateTime());
                } else if (row[31] instanceof LocalDateTime) {
                    p.setRejectedAt((LocalDateTime) row[31]);
                }
            }
            
            if (row[32] != null) {
                p.setRejectedBy(((Number) row[32]).longValue());
            }
        }
        
        return p;
    }
}
