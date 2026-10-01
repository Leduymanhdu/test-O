package com.uth.labodc.repository;

import com.uth.labodc.model.entity.User;
import com.uth.labodc.model.enums.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    Optional<User> findByEmailAndDeletedAtIsNull(String email);
    
    Boolean existsByEmail(String email);
    
    List<User> findByRole(UserRole role);
    
    Optional<User> findByVerificationToken(String token);
    
    // Search users by email or id for admin
    List<User> findTop10ByEmailContainingIgnoreCaseAndDeletedAtIsNullOrderByEmailAsc(String email);
}
