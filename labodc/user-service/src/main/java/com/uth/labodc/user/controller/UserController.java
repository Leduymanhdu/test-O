package com.uth.labodc.user.controller;

import com.uth.labodc.user.dto.UpdateMeRequest;
import com.uth.labodc.user.dto.UserProfileResponse;
import com.uth.labodc.user.model.UserProfile;
import com.uth.labodc.user.security.AuthenticatedUser;
import com.uth.labodc.user.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserProfileService service;

    public UserController(UserProfileService service) {
        this.service = service;
    }

    @GetMapping("/me")
    public UserProfileResponse me(Authentication authentication) {
        AuthenticatedUser user = (AuthenticatedUser) authentication.getPrincipal();
        UserProfile profile = service.getOrCreateMe(user);
        return toResponse(profile);
    }

    @PutMapping("/me")
    public UserProfileResponse updateMe(@Valid @RequestBody UpdateMeRequest request, Authentication authentication) {
        AuthenticatedUser user = (AuthenticatedUser) authentication.getPrincipal();
        UserProfile profile = service.updateMe(user, request);
        return toResponse(profile);
    }

    @GetMapping("/by-role/{role}")
    public List<UserProfileResponse> byRole(@PathVariable String role) {
        return service.findByRole(role).stream().map(this::toResponse).toList();
    }

    private UserProfileResponse toResponse(UserProfile profile) {
        return new UserProfileResponse(
                String.valueOf(profile.getId()),
                profile.getFullName(),
                profile.getEmail(),
                profile.getRole(),
                profile.getSkills(),
                profile.getPortfolioUrl()
        );
    }
}
