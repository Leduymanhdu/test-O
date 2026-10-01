package com.uth.labodc.service;

import com.uth.labodc.dto.TalentDTO;
import com.uth.labodc.model.entity.Talent;
import com.uth.labodc.model.entity.TalentSkill;
import com.uth.labodc.model.entity.User;
import java.math.BigDecimal;
import com.uth.labodc.model.enums.ProjectStatus;
import com.uth.labodc.repository.ProjectMemberRepository;
import com.uth.labodc.repository.TalentRepository;
import com.uth.labodc.repository.TalentSkillRepository;
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
public class TalentAdminService {
    
    private final TalentRepository talentRepository;
    private final TalentSkillRepository talentSkillRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final UserRepository userRepository;
    
    public User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }
    
    @Transactional(readOnly = true)
    public Page<TalentDTO> getAllTalents(Pageable pageable) {
        return talentRepository.findAll(pageable)
                .map(this::convertToDTO);
    }
    
    @Transactional(readOnly = true)
    public TalentDTO getTalentById(Long id) {
        Talent talent = talentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Talent not found with id: " + id));
        return convertToDTO(talent);
    }
    
    @Transactional
    public TalentDTO createTalent(TalentDTO dto, Long userId) {
        log.info("Creating new talent by user: {}", userId);
        
        // Validation: Check if user already has a talent profile
        if (talentRepository.existsByUserId(userId)) {
            throw new RuntimeException("User này đã có hồ sơ sinh viên");
        }
        
        // Validation: Check if studentId is unique (if provided)
        if (dto.getStudentId() != null && !dto.getStudentId().trim().isEmpty()) {
            if (talentRepository.existsByStudentId(dto.getStudentId())) {
                throw new RuntimeException("Mã sinh viên '" + dto.getStudentId() + "' đã tồn tại");
            }
        }
        
        Talent talent = new Talent();
        talent.setUserId(userId);
        talent.setFullName(dto.getFullName());
        talent.setStudentId(dto.getStudentId());
        talent.setDateOfBirth(dto.getDateOfBirth());
        talent.setFaculty(dto.getFaculty());
        talent.setMajor(dto.getMajor());
        talent.setYearOfStudy(dto.getYearOfStudy());
        talent.setGpa(dto.getGpa() != null ? BigDecimal.valueOf(dto.getGpa()) : null);
        talent.setGithubUrl(dto.getGithubUrl());
        talent.setLinkedinUrl(dto.getLinkedinUrl());
        talent.setPortfolioUrl(dto.getPortfolioUrl());
        talent.setBio(dto.getBio());
        talent.setAvailableForProjects(dto.getAvailable() != null ? dto.getAvailable() : true);
        talent.setCreatedAt(LocalDateTime.now());
        talent.setUpdatedAt(LocalDateTime.now());
        
        Talent saved = talentRepository.save(talent);
        
        // Add skills if provided
        if (dto.getSkills() != null) {
            for (String skillName : dto.getSkills()) {
                TalentSkill skill = new TalentSkill();
                skill.setTalentId(saved.getId());
                skill.setSkillName(skillName);
                skill.setProficiencyLevel(TalentSkill.SkillLevel.INTERMEDIATE); // Default proficiency level
                skill.setCreatedAt(LocalDateTime.now());
                talentSkillRepository.save(skill);
            }
        }
        
        log.info("Talent created with id: {}", saved.getId());
        return convertToDTO(saved);
    }
    
    @Transactional
    public TalentDTO updateTalent(Long id, TalentDTO dto) {
        log.info("Updating talent with id: {}", id);
        
        Talent talent = talentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Talent not found with id: " + id));
        
        // Update basic fields
        talent.setFullName(dto.getFullName());
        talent.setStudentId(dto.getStudentId());
        talent.setDateOfBirth(dto.getDateOfBirth());
        talent.setFaculty(dto.getFaculty());
        talent.setMajor(dto.getMajor());
        talent.setYearOfStudy(dto.getYearOfStudy());
        talent.setGpa(dto.getGpa() != null ? BigDecimal.valueOf(dto.getGpa()) : null);
        talent.setGithubUrl(dto.getGithubUrl());
        talent.setLinkedinUrl(dto.getLinkedinUrl());
        talent.setPortfolioUrl(dto.getPortfolioUrl());
        talent.setBio(dto.getBio());
        talent.setAvailableForProjects(dto.getAvailable());
        talent.setUpdatedAt(LocalDateTime.now());
        
        // Update user status if provided (Lab Admin can change status)
        if (dto.getStatus() != null) {
            User user = userRepository.findById(talent.getUserId())
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + talent.getUserId()));
            user.setStatus(com.uth.labodc.model.enums.UserStatus.valueOf(dto.getStatus()));
            user.setUpdatedAt(LocalDateTime.now());
            userRepository.save(user);
            log.info("User status updated to {} for talent {}", dto.getStatus(), id);
        }
        
        Talent saved = talentRepository.save(talent);
        
        // Update skills if provided
        if (dto.getSkills() != null) {
            // Delete existing skills
            List<TalentSkill> existingSkills = talentSkillRepository.findByTalentId(id);
            if (!existingSkills.isEmpty()) {
                talentSkillRepository.deleteAll(existingSkills);
                talentSkillRepository.flush(); // Ensure deletion is committed before inserting new ones
            }
            
            // Add new skills
            for (String skillName : dto.getSkills()) {
                TalentSkill skill = new TalentSkill();
                skill.setTalentId(id);
                skill.setSkillName(skillName);
                skill.setProficiencyLevel(TalentSkill.SkillLevel.INTERMEDIATE); // Default proficiency level
                skill.setCreatedAt(LocalDateTime.now());
                talentSkillRepository.save(skill);
            }
        }
        
        log.info("Talent {} updated successfully", id);
        return convertToDTO(saved);
    }
    
    @Transactional
    public void deleteTalent(Long id) {
        log.info("Deleting talent with id: {}", id);
        
        // Delete skills first
        talentSkillRepository.deleteByTalentId(id);
        
        // Delete talent
        talentRepository.deleteById(id);
        
        log.info("Talent {} deleted successfully", id);
    }
    
    private TalentDTO convertToDTO(Talent talent) {
        // Get user info
        User user = userRepository.findById(talent.getUserId())
                .orElse(null);
        String userEmail = user != null ? user.getEmail() : null;
        String userStatus = user != null ? user.getStatus().name() : "PENDING";
        
        // Get skills
        List<String> skills = talentSkillRepository.findByTalentId(talent.getId())
                .stream()
                .map(TalentSkill::getSkillName)
                .collect(Collectors.toList());
        
        Integer totalProjects = projectMemberRepository.countDistinctProjectIdByTalentId(talent.getId());
        Integer completedProjects = projectMemberRepository.countDistinctProjectIdByTalentIdAndProjectStatus(
                talent.getId(), ProjectStatus.COMPLETED);
        Integer ongoingProjects = projectMemberRepository.countDistinctProjectIdByTalentIdAndProjectStatus(
                talent.getId(), ProjectStatus.IN_PROGRESS);
        
        return TalentDTO.builder()
                .id(talent.getId())
                .userId(talent.getUserId())
                .userEmail(userEmail)
                .fullName(talent.getFullName())
                .studentId(talent.getStudentId())
                .dateOfBirth(talent.getDateOfBirth())
                .faculty(talent.getFaculty())
                .major(talent.getMajor())
                .yearOfStudy(talent.getYearOfStudy())
                .gpa(talent.getGpa() != null ? talent.getGpa().doubleValue() : null)
                .githubUrl(talent.getGithubUrl())
                .linkedinUrl(talent.getLinkedinUrl())
                .portfolioUrl(talent.getPortfolioUrl())
                .bio(talent.getBio())
                .skills(skills)
                .topSkills(String.join(", ", skills))
                .ratingAverage(talent.getRatingAverage() != null ? talent.getRatingAverage().doubleValue() : null)
                .totalRatings(0)
                .totalProjects(totalProjects)
                .completedProjects(completedProjects)
                .ongoingProjects(ongoingProjects)
                .available(talent.getAvailableForProjects())
                .status(userStatus)
                .createdAt(talent.getCreatedAt())
                .updatedAt(talent.getUpdatedAt())
                .build();
    }
}
