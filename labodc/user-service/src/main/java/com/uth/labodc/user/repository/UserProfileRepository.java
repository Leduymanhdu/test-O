package com.uth.labodc.user.repository;

import com.uth.labodc.user.model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {

    Optional<UserProfile> findByEmailIgnoreCase(String email);

    List<UserProfile> findAllByRoleIgnoreCase(String role);
}
