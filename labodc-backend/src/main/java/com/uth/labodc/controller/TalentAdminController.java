package com.uth.labodc.controller;

import com.uth.labodc.dto.TalentDTO;
import com.uth.labodc.service.TalentAdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/lab-admin/talents")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
public class TalentAdminController {
    
    private final TalentAdminService talentAdminService;
    
    @GetMapping
    public ResponseEntity<Page<TalentDTO>> getAllTalents(Pageable pageable) {
        log.info("Fetching all talents with pagination: {}", pageable);
        Page<TalentDTO> talents = talentAdminService.getAllTalents(pageable);
        return ResponseEntity.ok(talents);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TalentDTO> getTalentById(@PathVariable Long id) {
        log.info("Fetching talent with id: {}", id);
        TalentDTO talent = talentAdminService.getTalentById(id);
        return ResponseEntity.ok(talent);
    }
    
    @PostMapping
    public ResponseEntity<TalentDTO> createTalent(
            @RequestBody TalentDTO dto) {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        log.info("Creating new talent by user: {}", userEmail);
        
        // Get userId from userEmail
        com.uth.labodc.model.entity.User user = talentAdminService.findUserByEmail(userEmail);
        TalentDTO created = talentAdminService.createTalent(dto, user.getId());
        return ResponseEntity.ok(created);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<TalentDTO> updateTalent(
            @PathVariable Long id,
            @RequestBody TalentDTO dto) {
        log.info("Updating talent with id: {}", id);
        TalentDTO updated = talentAdminService.updateTalent(id, dto);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTalent(@PathVariable Long id) {
        log.info("Deleting talent with id: {}", id);
        talentAdminService.deleteTalent(id);
        return ResponseEntity.ok().build();
    }
}
