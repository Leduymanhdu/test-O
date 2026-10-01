package com.uth.labodc.service;

import com.uth.labodc.dto.EnterpriseDTO;
import com.uth.labodc.model.entity.Enterprise;
import com.uth.labodc.model.entity.EnterpriseRejection;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.model.enums.EnterpriseStatus;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.EnterpriseRepository;
import com.uth.labodc.repository.EnterpriseRejectionRepository;
import com.uth.labodc.repository.ProjectRepository;
import com.uth.labodc.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class EnterpriseService {
    
    private final EnterpriseRepository enterpriseRepository;
    private final EnterpriseRejectionRepository enterpriseRejectionRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    
    public User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }
    
    public List<User> searchUsers(String query) {
        return userRepository.findTop10ByEmailContainingIgnoreCaseAndDeletedAtIsNullOrderByEmailAsc(query);
    }
    
    @Transactional(readOnly = true)
    public Enterprise findById(Long id) {
        Enterprise enterprise = enterpriseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Enterprise not found with id: " + id));
        
        // Load rejection info if enterprise was rejected
        if (EnterpriseStatus.REJECTED.equals(enterprise.getStatus())) {
            List<EnterpriseRejection> rejections = enterpriseRejectionRepository
                    .findByEnterpriseIdOrderByRejectedAtDesc(id);
            if (!rejections.isEmpty()) {
                EnterpriseRejection latestRejection = rejections.get(0);
                enterprise.setRejectionReason(latestRejection.getRejectionReason());
                enterprise.setRejectedAt(latestRejection.getRejectedAt());
                enterprise.setRejectedBy(latestRejection.getRejectedBy());
            }
        }
        
        return enterprise;
    }
    
    @Transactional(readOnly = true)
    public List<Enterprise> findAll() {
        return enterpriseRepository.findAll();
    }
    
    @Transactional
    public Enterprise verifyEnterprise(Long id, Long verifiedBy) {
        log.info("Verifying enterprise with id: {}", id);
        
        Enterprise enterprise = findById(id);
        
        if (EnterpriseStatus.APPROVED.equals(enterprise.getStatus())) {
            throw new RuntimeException("Enterprise is already approved");
        }
        
        enterprise.setStatus(EnterpriseStatus.APPROVED);
        enterprise.setVerifiedAt(LocalDateTime.now());
        enterprise.setVerifiedBy(verifiedBy);
        
        Enterprise saved = enterpriseRepository.save(enterprise);
        log.info("Enterprise {} approved successfully", id);
        
        return saved;
    }
    
    @Transactional
    public void deleteEnterprise(Long id, Long rejectedBy, String reason) {
        log.info("Rejecting enterprise with id: {}", id);
        
        Enterprise enterprise = findById(id);
        
        // Update enterprise: set status = REJECTED
        enterprise.setStatus(EnterpriseStatus.REJECTED);
        enterprise.setVerifiedAt(LocalDateTime.now());
        enterprise.setVerifiedBy(rejectedBy);
        enterpriseRepository.save(enterprise);
        log.info("Enterprise {} marked as REJECTED", id);
        
        // Save rejection record with rejection reason
        EnterpriseRejection rejection = EnterpriseRejection.builder()
                .enterpriseId(id)
                .rejectedBy(rejectedBy)
                .rejectionReason(reason)
                .rejectedAt(LocalDateTime.now())
                .companyName(enterprise.getCompanyName())
                .taxCode(enterprise.getTaxCode())
                .contactEmail(enterprise.getContactEmail())
                .build();
        
        enterpriseRejectionRepository.save(rejection);
        log.info("Rejection record saved for enterprise {} ({}): {}", id, enterprise.getCompanyName(), reason);
        
        log.info("Enterprise {} rejected successfully", id);
    }
    
    // ===== LAB ADMIN METHODS =====
    
    @Transactional(readOnly = true)
    public Page<EnterpriseDTO> getAllEnterprises(Pageable pageable) {
        return enterpriseRepository.findAll(pageable)
                .map(this::convertToDTO);
    }
    
    @Transactional(readOnly = true)
    public EnterpriseDTO getEnterpriseById(Long id) {
        Enterprise enterprise = findById(id);
        return convertToDTO(enterprise);
    }
    
    @Transactional
    public EnterpriseDTO createEnterprise(EnterpriseDTO dto, Long userId) {
        log.info("Creating new enterprise by user: {}", userId);
        
        // Check if tax code already exists
        if (dto.getTaxCode() != null && enterpriseRepository.existsByTaxCode(dto.getTaxCode())) {
            throw new RuntimeException("Mã số thuế '" + dto.getTaxCode() + "' đã tồn tại trong hệ thống");
        }
        
        // Check if user already has an enterprise
        if (enterpriseRepository.existsByUserId(userId)) {
            throw new RuntimeException("User này đã có doanh nghiệp trong hệ thống");
        }
        
        Enterprise enterprise = new Enterprise();
        enterprise.setUserId(userId);
        enterprise.setCompanyName(dto.getCompanyName());
        enterprise.setTaxCode(dto.getTaxCode());
        enterprise.setBusinessLicenseNumber(dto.getBusinessLicenseNumber());
        enterprise.setAddress(dto.getAddress());
        enterprise.setCity(dto.getCity());
        enterprise.setDistrict(dto.getDistrict());
        enterprise.setWard(dto.getWard());
        enterprise.setRepresentativeName(dto.getRepresentativeName());
        enterprise.setRepresentativePosition(dto.getRepresentativePosition());
        enterprise.setContactEmail(dto.getContactEmail());
        enterprise.setContactPhone(dto.getContactPhone());
        enterprise.setWebsite(dto.getWebsite());
        enterprise.setIndustry(dto.getIndustry());
        enterprise.setCompanySize(dto.getCompanySize());
        enterprise.setYearEstablished(dto.getYearEstablished());
        enterprise.setDescription(dto.getDescription());
        enterprise.setStatus(EnterpriseStatus.PENDING);
        enterprise.setCreatedAt(LocalDateTime.now());
        enterprise.setUpdatedAt(LocalDateTime.now());
        
        Enterprise saved = enterpriseRepository.save(enterprise);
        log.info("Enterprise created with id: {}", saved.getId());
        
        return convertToDTO(saved);
    }
    
    @Transactional
    public EnterpriseDTO updateEnterprise(Long id, EnterpriseDTO dto) {
        log.info("Updating enterprise with id: {}", id);
        
        Enterprise enterprise = findById(id);
        
        // Update fields
        enterprise.setCompanyName(dto.getCompanyName());
        enterprise.setTaxCode(dto.getTaxCode());
        enterprise.setBusinessLicenseNumber(dto.getBusinessLicenseNumber());
        enterprise.setAddress(dto.getAddress());
        enterprise.setCity(dto.getCity());
        enterprise.setDistrict(dto.getDistrict());
        enterprise.setWard(dto.getWard());
        enterprise.setRepresentativeName(dto.getRepresentativeName());
        enterprise.setRepresentativePosition(dto.getRepresentativePosition());
        enterprise.setContactEmail(dto.getContactEmail());
        enterprise.setContactPhone(dto.getContactPhone());
        enterprise.setWebsite(dto.getWebsite());
        enterprise.setIndustry(dto.getIndustry());
        enterprise.setCompanySize(dto.getCompanySize());
        enterprise.setYearEstablished(dto.getYearEstablished());
        enterprise.setDescription(dto.getDescription());
        
        // Update status if provided (Lab Admin can change status manually)
        if (dto.getStatus() != null) {
            enterprise.setStatus(EnterpriseStatus.valueOf(dto.getStatus()));
        }
        
        enterprise.setUpdatedAt(LocalDateTime.now());
        
        Enterprise saved = enterpriseRepository.save(enterprise);
        log.info("Enterprise {} updated successfully", id);
        
        return convertToDTO(saved);
    }
    
    private EnterpriseDTO convertToDTO(Enterprise enterprise) {
        // Get user email
        String userEmail = userRepository.findById(enterprise.getUserId())
                .map(User::getEmail)
                .orElse(null);
        
        // Get verifier name if verified
        String verifiedByName = null;
        if (enterprise.getVerifiedBy() != null) {
            verifiedByName = userRepository.findById(enterprise.getVerifiedBy())
                    .map(User::getEmail)
                    .orElse(null);
        }
        
        // Get project stats
        Integer totalProjects = projectRepository.countByEnterpriseId(enterprise.getId());
        Integer activeProjects = projectRepository.countByEnterpriseIdAndStatus(
                enterprise.getId(), ProjectStatus.IN_PROGRESS);
        
        return EnterpriseDTO.builder()
                .id(enterprise.getId())
                .userId(enterprise.getUserId())
                .userEmail(userEmail)
                .companyName(enterprise.getCompanyName())
                .taxCode(enterprise.getTaxCode())
                .businessLicenseNumber(enterprise.getBusinessLicenseNumber())
                .address(enterprise.getAddress())
                .city(enterprise.getCity())
                .district(enterprise.getDistrict())
                .ward(enterprise.getWard())
                .representativeName(enterprise.getRepresentativeName())
                .representativePosition(enterprise.getRepresentativePosition())
                .contactEmail(enterprise.getContactEmail())
                .contactPhone(enterprise.getContactPhone())
                .website(enterprise.getWebsite())
                .industry(enterprise.getIndustry())
                .companySize(enterprise.getCompanySize())
                .yearEstablished(enterprise.getYearEstablished())
                .description(enterprise.getDescription())
                .status(enterprise.getStatus().name())
                .verifiedAt(enterprise.getVerifiedAt())
                .verifiedBy(enterprise.getVerifiedBy())
                .verifiedByName(verifiedByName)
                .createdAt(enterprise.getCreatedAt())
                .updatedAt(enterprise.getUpdatedAt())
                .totalProjects(totalProjects)
                .activeProjects(activeProjects)
                .build();
    }
}
