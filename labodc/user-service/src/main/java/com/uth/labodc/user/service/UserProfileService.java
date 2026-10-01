package com.uth.labodc.user.service;

import com.uth.labodc.user.dto.UpdateMeRequest;
import com.uth.labodc.user.model.UserProfile;
import com.uth.labodc.user.repository.UserProfileRepository;
import com.uth.labodc.user.security.AuthenticatedUser;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserProfileService {

    private final UserProfileRepository repository;

    public UserProfileService(UserProfileRepository repository) {
        this.repository = repository;
    }

    public UserProfile getOrCreateMe(AuthenticatedUser user) {
        Long id = Long.parseLong(user.userId());
        return repository.findById(id).orElseGet(() -> repository.save(
                new UserProfile(
                        id,
                user.email(),
                        user.email(),
                        user.role(),
                        null,
                        null
                )
        ));
    }

    public UserProfile updateMe(AuthenticatedUser user, UpdateMeRequest request) {
        UserProfile profile = getOrCreateMe(user);
        profile.setFullName(request.fullName());
        profile.setSkills(request.skills());
        profile.setPortfolioUrl(request.portfolioUrl());
        profile.setRole(user.role());
        return repository.save(profile);
    }

    public List<UserProfile> findByRole(String role) {
        return repository.findAllByRoleIgnoreCase(role);
    }
}
