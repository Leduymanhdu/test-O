package com.uth.labodc.controller;

import com.uth.labodc.dto.EnterpriseDTO;
import com.uth.labodc.service.EnterpriseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/lab-admin/enterprises")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasAnyRole('LAB_ADMIN', 'SYSTEM_ADMIN')")
public class EnterpriseAdminController {
    
    private final EnterpriseService enterpriseService;
    
    @GetMapping
    public ResponseEntity<Page<EnterpriseDTO>> getAllEnterprises(Pageable pageable) {
        log.info("Fetching all enterprises with pagination: {}", pageable);
        Page<EnterpriseDTO> enterprises = enterpriseService.getAllEnterprises(pageable);
        return ResponseEntity.ok(enterprises);
    }
    
    @GetMapping("/search-users")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> searchUsers(@RequestParam String query) {
        log.info("Searching users with query: {}", query);
        java.util.List<com.uth.labodc.model.entity.User> users = enterpriseService.searchUsers(query);
        java.util.List<java.util.Map<String, Object>> result = users.stream()
            .map(user -> {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("id", user.getId());
                map.put("email", user.getEmail());
                map.put("role", user.getRole().name());
                return map;
            })
            .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<EnterpriseDTO> getEnterpriseById(@PathVariable Long id) {
        log.info("Fetching enterprise with id: {}", id);
        EnterpriseDTO enterprise = enterpriseService.getEnterpriseById(id);
        return ResponseEntity.ok(enterprise);
    }
    
    @PostMapping
    public ResponseEntity<EnterpriseDTO> createEnterprise(
            @RequestBody EnterpriseDTO dto) {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        log.info("Creating new enterprise by user: {}", userEmail);
        
        // Get userId from userEmail
        com.uth.labodc.model.entity.User user = enterpriseService.findUserByEmail(userEmail);
        EnterpriseDTO created = enterpriseService.createEnterprise(dto, user.getId());
        return ResponseEntity.ok(created);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<EnterpriseDTO> updateEnterprise(
            @PathVariable Long id,
            @RequestBody EnterpriseDTO dto) {
        log.info("Updating enterprise with id: {}", id);
        EnterpriseDTO updated = enterpriseService.updateEnterprise(id, dto);
        return ResponseEntity.ok(updated);
    }
    
    @PostMapping("/{id}/verify")
    public ResponseEntity<?> verifyEnterprise(@PathVariable Long id) {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        
        // Get userId from userEmail
        com.uth.labodc.model.entity.User user = enterpriseService.findUserByEmail(userEmail);
        log.info("Verifying enterprise {} by user {}", id, user.getId());
        enterpriseService.verifyEnterprise(id, user.getId());
        return ResponseEntity.ok().build();
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteEnterprise(
            @PathVariable Long id,
            @RequestParam String reason) {
        org.springframework.security.core.Authentication authentication = 
            org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        
        // Get userId from userEmail
        com.uth.labodc.model.entity.User user = enterpriseService.findUserByEmail(userEmail);
        log.info("Deleting/rejecting enterprise {} by user {}", id, user.getId());
        enterpriseService.deleteEnterprise(id, user.getId(), reason);
        return ResponseEntity.ok().build();
    }
}
