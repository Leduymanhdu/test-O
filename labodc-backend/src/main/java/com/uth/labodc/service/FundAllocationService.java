package com.uth.labodc.service;

import com.uth.labodc.dto.fund.*;
import com.uth.labodc.model.entity.*;
import com.uth.labodc.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class FundAllocationService {
    
    private final ProjectRepository projectRepository;
    private final PaymentRepository paymentRepository;
    private final FundAllocationRepository fundAllocationRepository;
    private final FundDistributionRepository fundDistributionRepository;
    private final TeamFundDistributionRepository teamFundDistributionRepository;
    private final TeamMemberAllocationRepository teamMemberAllocationRepository;
    private final EnterpriseRepository enterpriseRepository;
    
    // Fund allocation percentages (70% team, 20% mentor, 10% lab)
    private static final BigDecimal TEAM_PERCENTAGE = new BigDecimal("70");
    private static final BigDecimal MENTOR_PERCENTAGE = new BigDecimal("20");
    private static final BigDecimal LAB_PERCENTAGE = new BigDecimal("10");
    private static final BigDecimal HUNDRED = new BigDecimal("100");
    
    /**
     * Get fund allocation statistics
     */
    public FundAllocationStatsDTO getFundAllocationStats() {
        List<FundAllocation> allAllocations = fundAllocationRepository.findAll();
        
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal teamDisbursed = BigDecimal.ZERO;
        BigDecimal mentorDisbursed = BigDecimal.ZERO;
        BigDecimal labReceived = BigDecimal.ZERO;
        long pendingDistributions = 0;
        
        for (FundAllocation allocation : allAllocations) {
            totalAmount = totalAmount.add(allocation.getTotalAmount());
            
            // Get distributions for this allocation
            List<FundDistribution> distributions = fundDistributionRepository.findByAllocationId(allocation.getId());
            
            for (FundDistribution dist : distributions) {
                if ("COMPLETED".equals(dist.getStatus())) {
                    if ("TEAM".equals(dist.getRecipientType()) || "TALENT".equals(dist.getRecipientType())) {
                        teamDisbursed = teamDisbursed.add(dist.getAmount());
                    } else if ("MENTOR".equals(dist.getRecipientType())) {
                        mentorDisbursed = mentorDisbursed.add(dist.getAmount());
                    } else if ("LAB".equals(dist.getRecipientType())) {
                        labReceived = labReceived.add(dist.getAmount());
                    }
                } else if ("PENDING".equals(dist.getStatus())) {
                    pendingDistributions++;
                }
            }
        }
        
        return FundAllocationStatsDTO.builder()
                .totalAllocations((long) allAllocations.size())
                .totalAmount(totalAmount)
                .teamDisbursed(teamDisbursed)
                .mentorDisbursed(mentorDisbursed)
                .labReceived(labReceived)
                .pendingDistributions(pendingDistributions)
                .build();
    }
    
    /**
     * Get all fund allocations with optional status filter
     */
    public List<FundAllocationDTO> getAllFundAllocations(String statusFilter) {
        log.info("Getting all fund allocations with status filter: {}", statusFilter);
        List<FundAllocation> allocations;
        
        if (statusFilter != null && !statusFilter.isEmpty()) {
            allocations = fundAllocationRepository.findByStatus(statusFilter.toUpperCase());
        } else {
            allocations = fundAllocationRepository.findAll();
        }
        
        log.info("Found {} fund allocations in database", allocations.size());
        
        List<FundAllocationDTO> result = new ArrayList<>();
        
        for (FundAllocation allocation : allocations) {
            try {
                FundAllocationDTO dto = mapToFundAllocationDTO(allocation);
                if (dto != null) {
                    result.add(dto);
                } else {
                    log.warn("Skipping allocation {} - mapping returned null", allocation.getId());
                }
            } catch (Exception e) {
                log.error("Error mapping allocation {}: {}", allocation.getId(), e.getMessage(), e);
            }
        }
        
        log.info("Successfully mapped {} fund allocations", result.size());
        return result;
    }
    
    /**
     * Get fund allocation details for a project
     */
    public FundAllocationDTO getFundAllocationByProjectId(Long projectId) {
        FundAllocation allocation = fundAllocationRepository.findByProjectId(projectId)
                .orElseThrow(() -> new RuntimeException("Fund allocation not found for project: " + projectId));
        
        return mapToFundAllocationDTO(allocation);
    }
    
    /**
     * Disburse funds to mentor
     */
    @Transactional
    public void disburseMentorFunds(Long projectId, DisburseMentorRequest request) {
        log.info("Disbursing mentor funds for project {}: {} to mentor {}", 
                projectId, request.getAmount(), request.getMentorId());
        
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        FundAllocation allocation = fundAllocationRepository.findByProjectId(projectId)
                .orElseThrow(() -> new RuntimeException("Fund allocation not found for project: " + projectId));

        BigDecimal amount = request.getAmount() != null ? request.getAmount() : allocation.getMentorAmount();
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Invalid mentor disbursement amount");
        }
        if (amount.compareTo(allocation.getMentorAmount()) > 0) {
            throw new RuntimeException("Mentor disbursement exceeds allocated mentor amount");
        }

        Long mentorId = request.getMentorId() != null ? request.getMentorId() : project.getMentorId();
        if (mentorId == null) {
            throw new RuntimeException("Mentor ID is required for disbursement");
        }

        FundDistribution distribution = FundDistribution.builder()
                .allocationId(allocation.getId())
                .recipientType("MENTOR")
                .recipientId(mentorId)
                .amount(amount)
                .status("COMPLETED")
                .disbursedAt(java.time.LocalDateTime.now())
                .disbursedBy(allocation.getValidatedBy())
                .build();

        fundDistributionRepository.save(distribution);
        log.info("Mentor funds disbursed successfully. Note: {}", request.getNote());
    }
    
    /**
     * Disburse funds to team members
     */
    @Transactional
    public void disburseTeamFunds(Long projectId, DisburseTeamRequest request) {
        log.info("Disbursing team funds for project {}", projectId);
        
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        FundAllocation allocation = fundAllocationRepository.findByProjectId(projectId)
                .orElseThrow(() -> new RuntimeException("Fund allocation not found for project: " + projectId));

        if (request.getTeamDistribution() == null || request.getTeamDistribution().isEmpty()) {
            throw new RuntimeException("Team distribution list is required");
        }

        BigDecimal totalRequested = request.getTeamDistribution().stream()
                .map(DisburseTeamRequest.TeamMemberDisbursement::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (totalRequested.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Total team disbursement amount must be positive");
        }
        if (totalRequested.compareTo(allocation.getTeamAmount()) > 0) {
            throw new RuntimeException("Team disbursement exceeds allocated team amount");
        }

        TeamFundDistribution teamDistribution;
        if (request.getDistributionId() != null) {
            teamDistribution = teamFundDistributionRepository.findById(request.getDistributionId())
                    .orElseThrow(() -> new RuntimeException("Team distribution not found: " + request.getDistributionId()));
            teamDistribution.setTotalTeamAmount(totalRequested);
            teamDistribution.setStatus("DISBURSED");
            teamDistribution.setApprovedByLab(allocation.getValidatedBy());
            teamDistribution.setApprovedByLabAt(java.time.LocalDateTime.now());
            teamDistribution = teamFundDistributionRepository.save(teamDistribution);
        } else {
            Long submittedBy = request.getTeamDistribution().get(0).getTalentId();
            if (submittedBy == null) {
                throw new RuntimeException("SubmittedBy talentId is required for team distribution");
            }

            teamDistribution = TeamFundDistribution.builder()
                    .projectId(projectId)
                    .allocationId(allocation.getId())
                    .submittedBy(submittedBy)
                    .totalTeamAmount(totalRequested)
                    .status("DISBURSED")
                    .approvedByLab(allocation.getValidatedBy())
                    .approvedByLabAt(java.time.LocalDateTime.now())
                    .build();
            teamDistribution = teamFundDistributionRepository.save(teamDistribution);
        }

        for (DisburseTeamRequest.TeamMemberDisbursement member : request.getTeamDistribution()) {
            if (member.getTalentId() == null) {
                throw new RuntimeException("Talent ID is required for team disbursement");
            }
            if (member.getAmount() == null || member.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new RuntimeException("Invalid disbursement amount for talent " + member.getTalentId());
            }

            BigDecimal percentage = member.getAmount()
                    .multiply(HUNDRED)
                    .divide(totalRequested, 2, RoundingMode.HALF_UP);

            TeamMemberAllocation allocationMember = TeamMemberAllocation.builder()
                    .distributionId(teamDistribution.getId())
                    .talentId(member.getTalentId())
                    .amount(member.getAmount())
                    .percentage(percentage)
                    .reason(request.getNote())
                    .build();
            teamMemberAllocationRepository.save(allocationMember);

            FundDistribution distribution = FundDistribution.builder()
                    .allocationId(allocation.getId())
                    .recipientType("TALENT")
                    .recipientId(member.getTalentId())
                    .amount(member.getAmount())
                    .status("COMPLETED")
                    .disbursedAt(java.time.LocalDateTime.now())
                    .disbursedBy(allocation.getValidatedBy())
                    .build();
            fundDistributionRepository.save(distribution);

            log.info("Disbursing {} to talent {}", member.getAmount(), member.getTalentId());
        }

        log.info("Team funds disbursed successfully. Note: {}", request.getNote());
    }
    
    /**
     * Map FundAllocation entity to FundAllocationDTO
     */
    private FundAllocationDTO mapToFundAllocationDTO(FundAllocation allocation) {
        try {
            log.debug("Mapping allocation {} for project {}", allocation.getId(), allocation.getProjectId());
            
            // Get project details
            Project project = projectRepository.findById(allocation.getProjectId())
                    .orElse(null);
            
            if (project == null) {
                log.error("Project {} not found for allocation {}. This indicates missing seed data.", 
                        allocation.getProjectId(), allocation.getId());
                return null;
            }
            
            // Get payment details
            Payment payment = paymentRepository.findById(allocation.getPaymentId())
                    .orElse(null);
            
            // Get enterprise name
            String enterpriseName = "N/A";
            if (project.getEnterpriseId() != null) {
                enterpriseName = enterpriseRepository.findById(project.getEnterpriseId())
                        .map(Enterprise::getCompanyName)
                        .orElse("N/A");
            }
            
            // Build payment info
            FundAllocationDTO.PaymentInfo paymentInfo = FundAllocationDTO.PaymentInfo.builder()
                    .id(payment != null ? payment.getId() : allocation.getPaymentId())
                    .amount(allocation.getTotalAmount())
                    .status(payment != null ? payment.getStatus() : "UNKNOWN")
                    .paidAt(payment != null ? payment.getPaidAt() : null)
                    .build();
            
            // Get fund distributions for this allocation
            List<FundDistribution> distributions = fundDistributionRepository.findByAllocationId(allocation.getId());
            
            // Determine team status
            String teamStatus = "PENDING_DISTRIBUTION";
            TeamFundDistribution teamDist = teamFundDistributionRepository.findByProjectId(project.getId())
                    .orElse(null);
            if (teamDist != null) {
                teamStatus = teamDist.getStatus();
            } else {
                // Check if there are any team distributions in fund_distributions
                for (FundDistribution dist : distributions) {
                    if ("TEAM".equals(dist.getRecipientType()) || "TALENT".equals(dist.getRecipientType())) {
                        teamStatus = dist.getStatus();
                        break;
                    }
                }
            }
            
            // Determine mentor status
            String mentorStatus = "PENDING_REPORT";
            for (FundDistribution dist : distributions) {
                if ("MENTOR".equals(dist.getRecipientType())) {
                    mentorStatus = dist.getStatus();
                    break;
                }
            }
            
            // Determine lab status
            String labStatus = "PENDING";
            for (FundDistribution dist : distributions) {
                if ("LAB".equals(dist.getRecipientType())) {
                    labStatus = dist.getStatus();
                    break;
                }
            }
            
            // Build fund portions
            FundAllocationDTO.FundPortion teamPortion = FundAllocationDTO.FundPortion.builder()
                    .amount(allocation.getTeamAmount())
                    .percentage(allocation.getTeamPercentage().intValue())
                    .status(teamStatus)
                    .build();
            
            FundAllocationDTO.FundPortion mentorPortion = FundAllocationDTO.FundPortion.builder()
                    .amount(allocation.getMentorAmount())
                    .percentage(allocation.getMentorPercentage().intValue())
                    .status(mentorStatus)
                    .build();
            
            FundAllocationDTO.FundPortion labPortion = FundAllocationDTO.FundPortion.builder()
                    .amount(allocation.getLabAmount())
                    .percentage(allocation.getLabPercentage().intValue())
                    .status(labStatus)
                    .build();
            
            FundAllocationDTO.AllocationInfo allocationInfo = FundAllocationDTO.AllocationInfo.builder()
                    .total(allocation.getTotalAmount())
                    .team(teamPortion)
                    .mentor(mentorPortion)
                    .lab(labPortion)
                    .build();
            
            return FundAllocationDTO.builder()
                    .projectId(project.getId())
                    .projectTitle(project.getTitle())
                    .enterpriseName(enterpriseName)
                    .payment(paymentInfo)
                    .allocation(allocationInfo)
                    .status(allocation.getStatus())
                    .build();
        } catch (Exception e) {
            log.error("Error mapping fund allocation: {}", e.getMessage(), e);
            return null;
        }
    }
    
    /**
     * Update fund allocation
     */
    @Transactional
    public FundAllocationDTO updateFundAllocation(Long projectId, FundAllocationDTO dto) {
        log.info("Updating fund allocation for project: {}", projectId);
        
        FundAllocation allocation = fundAllocationRepository.findByProjectId(projectId)
                .orElseThrow(() -> new RuntimeException("Fund allocation not found for project: " + projectId));
        
        // Update status if provided
        if (dto.getStatus() != null && !dto.getStatus().isEmpty()) {
            allocation.setStatus(dto.getStatus());
        }
        
        fundAllocationRepository.save(allocation);
        log.info("Fund allocation updated for project: {}", projectId);
        
        return getFundAllocationByProjectId(projectId);
    }
    
    /**
     * Delete fund allocation
     */
    @Transactional
    public void deleteFundAllocation(Long projectId) {
        log.info("Deleting fund allocation for project: {}", projectId);
        
        FundAllocation allocation = fundAllocationRepository.findByProjectId(projectId)
                .orElseThrow(() -> new RuntimeException("Fund allocation not found for project: " + projectId));
        
        // Delete team distributions first (they reference allocation_id directly)
        List<TeamFundDistribution> teamDistributions = teamFundDistributionRepository.findByAllocationId(allocation.getId());
        if (!teamDistributions.isEmpty()) {
            teamFundDistributionRepository.deleteAll(teamDistributions);
            log.info("Deleted {} team fund distributions", teamDistributions.size());
        }
        
        // Delete fund distributions
        List<FundDistribution> distributions = fundDistributionRepository.findByAllocationId(allocation.getId());
        if (!distributions.isEmpty()) {
            fundDistributionRepository.deleteAll(distributions);
            log.info("Deleted {} fund distributions", distributions.size());
        }
        
        // Finally delete the allocation
        fundAllocationRepository.delete(allocation);
        log.info("Fund allocation deleted for project: {}", projectId);
    }
}
