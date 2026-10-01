package com.uth.labodc.controller;

import com.uth.labodc.dto.MentorDTO;
import com.uth.labodc.service.MentorAdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/lab-admin/mentors")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
public class MentorAdminController {
    
    private final MentorAdminService mentorAdminService;
    
    @GetMapping
    public ResponseEntity<Page<MentorDTO>> getAllMentors(Pageable pageable) {
        log.info("Fetching all mentors with pagination: {}", pageable);
        Page<MentorDTO> mentors = mentorAdminService.getAllMentors(pageable);
        return ResponseEntity.ok(mentors);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<MentorDTO> getMentorById(@PathVariable Long id) {
        log.info("Fetching mentor with id: {}", id);
        MentorDTO mentor = mentorAdminService.getMentorById(id);
        return ResponseEntity.ok(mentor);
    }
    
    @GetMapping("/expertise/all")
    public ResponseEntity<java.util.List<String>> getAllExpertise() {
        log.info("Fetching all distinct expertise from mentor_expertise table");
        java.util.List<String> expertise = mentorAdminService.getAllDistinctExpertise();
        return ResponseEntity.ok(expertise);
    }

    @GetMapping("/available")
    public ResponseEntity<com.uth.labodc.dto.ApiResponse<java.util.Map<String, Object>>> getAvailableMentors(
            @RequestParam(required = false) String technologies) {
        java.util.List<String> techList = java.util.Collections.emptyList();
        if (technologies != null && !technologies.trim().isEmpty()) {
            techList = java.util.Arrays.stream(technologies.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .toList();
        }
        java.util.List<MentorDTO> mentors = mentorAdminService.getAvailableMentors(techList);
        java.util.Map<String, Object> data = java.util.Map.of("mentors", mentors);
        return ResponseEntity.ok(com.uth.labodc.dto.ApiResponse.success(data));
    }
    
    @PostMapping
    public ResponseEntity<MentorDTO> createMentor(
            @RequestBody MentorDTO dto) {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        log.info("Creating new mentor by user: {}", userEmail);
        
        // Get userId from userEmail
        com.uth.labodc.model.entity.User user = mentorAdminService.findUserByEmail(userEmail);
        MentorDTO created = mentorAdminService.createMentor(dto, user.getId());
        return ResponseEntity.ok(created);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<MentorDTO> updateMentor(
            @PathVariable Long id,
            @RequestBody MentorDTO dto) {
        log.info("Updating mentor with id: {}", id);
        MentorDTO updated = mentorAdminService.updateMentor(id, dto);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMentor(@PathVariable Long id) {
        log.info("Deleting mentor with id: {}", id);
        mentorAdminService.deleteMentor(id);
        return ResponseEntity.ok().build();
    }
}
