package com.uth.labodc.service;

import com.uth.labodc.dto.MentorDTO;
import com.uth.labodc.model.entity.Mentor;
import com.uth.labodc.model.entity.MentorExpertise;
import com.uth.labodc.model.entity.User;
import com.uth.labodc.repository.MentorExpertiseRepository;
import com.uth.labodc.repository.MentorRepository;
import com.uth.labodc.repository.ProjectRepository;
import com.uth.labodc.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class MentorAdminService {
    
    private final MentorRepository mentorRepository;
    private final MentorExpertiseRepository mentorExpertiseRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    
    public User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }
    
    @Transactional(readOnly = true)
    public Page<MentorDTO> getAllMentors(Pageable pageable) {
        return mentorRepository.findAll(pageable)
                .map(this::convertToDTO);
    }
    
    @Transactional(readOnly = true)
    public MentorDTO getMentorById(Long id) {
        Mentor mentor = mentorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Mentor not found with id: " + id));
        return convertToDTO(mentor);
    }
    
    @Transactional
    public MentorDTO createMentor(MentorDTO dto, Long userId) {
        log.info("Creating new mentor by user: {}", userId);
        
        // Validation: Check if user already has a mentor profile
        if (mentorRepository.existsByUserId(userId)) {
            throw new RuntimeException("User này đã có hồ sơ mentor");
        }
        
        // Update user role to MENTOR if not already
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        if (!com.uth.labodc.model.enums.UserRole.MENTOR.equals(user.getRole())) {
            user.setRole(com.uth.labodc.model.enums.UserRole.MENTOR);
            userRepository.save(user);
            log.info("Updated user {} role to MENTOR", userId);
        }
        
        Mentor mentor = new Mentor();
        mentor.setUserId(userId);
        mentor.setFullName(dto.getFullName());
        mentor.setTitle(dto.getTitle());
        mentor.setCurrentPosition(dto.getCurrentPosition());
        mentor.setCurrentCompany(dto.getCurrentCompany());
        mentor.setYearsOfExperience(dto.getYearsOfExperience());
        mentor.setBio(dto.getBio());
        mentor.setLinkedinUrl(dto.getLinkedinUrl());
        mentor.setHourlyRate(dto.getHourlyRate() != null ? dto.getHourlyRate().longValue() : null);
        mentor.setMaxConcurrentProjects(dto.getMaxConcurrentProjects());
        mentor.setAvailable(dto.getAvailable() != null ? dto.getAvailable() : true);
        mentor.setCreatedAt(LocalDateTime.now());
        mentor.setUpdatedAt(LocalDateTime.now());
        
        Mentor saved = mentorRepository.save(mentor);
        
        // Add expertise if provided
        if (dto.getExpertise() != null) {
            for (String expertiseName : dto.getExpertise()) {
                MentorExpertise expertise = new MentorExpertise();
                expertise.setMentorId(saved.getId());
                expertise.setSkillName(expertiseName);
                expertise.setProficiencyLevel("EXPERT"); // Default proficiency level for mentors
                expertise.setCanTeach(true);
                expertise.setCreatedAt(LocalDateTime.now());
                mentorExpertiseRepository.save(expertise);
            }
        }
        
        log.info("Mentor created with id: {}", saved.getId());
        return convertToDTO(saved);
    }
    
    @Transactional
    public MentorDTO updateMentor(Long id, MentorDTO dto) {
        log.info("Updating mentor with id: {}", id);
        
        Mentor mentor = mentorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Mentor not found with id: " + id));
        
        // Update basic fields
        mentor.setFullName(dto.getFullName());
        mentor.setTitle(dto.getTitle());
        mentor.setCurrentPosition(dto.getCurrentPosition());
        mentor.setCurrentCompany(dto.getCurrentCompany());
        mentor.setYearsOfExperience(dto.getYearsOfExperience());
        mentor.setBio(dto.getBio());
        mentor.setLinkedinUrl(dto.getLinkedinUrl());
        mentor.setHourlyRate(dto.getHourlyRate() != null ? dto.getHourlyRate().longValue() : null);
        mentor.setMaxConcurrentProjects(dto.getMaxConcurrentProjects());
        mentor.setAvailable(dto.getAvailable());
        mentor.setUpdatedAt(LocalDateTime.now());
        
        // Update user status if provided (Lab Admin can change status)
        if (dto.getStatus() != null) {
            User user = userRepository.findById(mentor.getUserId())
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + mentor.getUserId()));
            user.setStatus(com.uth.labodc.model.enums.UserStatus.valueOf(dto.getStatus()));
            user.setUpdatedAt(LocalDateTime.now());
            userRepository.save(user);
            log.info("User status updated to {} for mentor {}", dto.getStatus(), id);
        }
        
        Mentor saved = mentorRepository.save(mentor);
        
        // Update expertise if provided
        if (dto.getExpertise() != null) {
            // Delete existing expertise
            List<MentorExpertise> existingExpertise = mentorExpertiseRepository.findByMentorId(id);
            if (!existingExpertise.isEmpty()) {
                mentorExpertiseRepository.deleteAll(existingExpertise);
                mentorExpertiseRepository.flush(); // Ensure deletion is committed before inserting new ones
            }
            
            // Add new expertise
            for (String expertiseName : dto.getExpertise()) {
                MentorExpertise expertise = new MentorExpertise();
                expertise.setMentorId(id);
                expertise.setSkillName(expertiseName);
                expertise.setProficiencyLevel("EXPERT"); // Default proficiency level for mentors
                expertise.setCanTeach(true);
                expertise.setCreatedAt(LocalDateTime.now());
                mentorExpertiseRepository.save(expertise);
            }
        }
        
        log.info("Mentor {} updated successfully", id);
        return convertToDTO(saved);
    }
    
    @Transactional
    public void deleteMentor(Long id) {
        log.info("Deleting mentor with id: {}", id);
        
        // Delete expertise first
        mentorExpertiseRepository.deleteByMentorId(id);
        
        // Delete mentor
        mentorRepository.deleteById(id);
        
        log.info("Mentor {} deleted successfully", id);
    }
    
    private MentorDTO convertToDTO(Mentor mentor) {
        // Get user info
        User user = userRepository.findById(mentor.getUserId())
                .orElse(null);
        String userEmail = user != null ? user.getEmail() : null;
        String userStatus = user != null ? user.getStatus().name() : "PENDING";
        
        // Get expertise
        List<String> expertise = mentorExpertiseRepository.findByMentorId(mentor.getId())
                .stream()
                .map(MentorExpertise::getSkillName)
                .collect(Collectors.toList());
        
        // Get project stats
        Integer totalProjects = projectRepository.countByMentorId(mentor.getId());
        Integer currentProjects = mentor.getCurrentProjectsCount();
        Integer completedProjects = totalProjects - (currentProjects != null ? currentProjects : 0);
        
        return MentorDTO.builder()
                .id(mentor.getId())
                .userId(mentor.getUserId())
                .userEmail(userEmail)
                .fullName(mentor.getFullName())
                .title(mentor.getTitle())
                .currentPosition(mentor.getCurrentPosition())
                .currentCompany(mentor.getCurrentCompany())
                .yearsOfExperience(mentor.getYearsOfExperience())
                .bio(mentor.getBio())
                .linkedinUrl(mentor.getLinkedinUrl())
                .expertise(expertise)
                .topExpertise(String.join(", ", expertise))
                .hourlyRate(mentor.getHourlyRate() != null ? mentor.getHourlyRate().doubleValue() : null)
                .currency("VND")
                .maxConcurrentProjects(mentor.getMaxConcurrentProjects())
                .currentProjects(currentProjects)
                .ratingAverage(mentor.getRatingAverage() != null ? mentor.getRatingAverage().doubleValue() : null)
                .totalRatings(0)
                .totalProjects(totalProjects)
                .completedProjects(completedProjects)
                .available(mentor.getAvailable())
                .status(userStatus)
                .createdAt(mentor.getCreatedAt())
                .updatedAt(mentor.getUpdatedAt())
                .build();
    }
    
    @Transactional(readOnly = true)
    public List<String> getAllDistinctExpertise() {
        log.info("Fetching all distinct expertise from mentor_expertise table");
        return mentorExpertiseRepository.findAllDistinctSkillNames();
    }

    @Transactional(readOnly = true)
    public List<MentorDTO> getAvailableMentors(List<String> technologies) {
        List<String> techFilters = technologies == null
                ? Collections.emptyList()
                : technologies.stream()
                    .filter(t -> t != null && !t.trim().isEmpty())
                    .map(t -> t.toLowerCase(Locale.ROOT))
                    .collect(Collectors.toList());

        List<MentorDTO> all = mentorRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());

        List<MentorDTO> available = new ArrayList<>();
        for (MentorDTO m : all) {
            if (m.getAvailable() != null && !m.getAvailable()) {
                continue;
            }
            if (techFilters.isEmpty()) {
                available.add(m);
                continue;
            }
            List<String> expertise = m.getExpertise();
            if (expertise == null || expertise.isEmpty()) {
                continue;
            }
            boolean match = expertise.stream()
                    .filter(e -> e != null)
                    .map(e -> e.toLowerCase(Locale.ROOT))
                    .anyMatch(e -> techFilters.stream().anyMatch(e::contains));
            if (match) {
                available.add(m);
            }
        }

        return available;
    }
}
