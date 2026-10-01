package com.uth.labodc.repository;

import com.uth.labodc.model.entity.Talent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface TalentRepository extends JpaRepository<Talent, Long> {
    
    Optional<Talent> findByUserId(Long userId);

    boolean existsByUserId(Long userId);

    boolean existsByStudentId(String studentId);
    
    @Query("SELECT COUNT(t) FROM Talent t WHERE t.createdAt >= :since")
    long countNewTalents(LocalDateTime since);
    
    @Query(value = "SELECT COUNT(t.id) FROM talents t JOIN users u ON t.user_id = u.id WHERE u.status = 'ACTIVE'", nativeQuery = true)
    long countActiveTalents();
    
    @Query("SELECT AVG(t.ratingAverage) FROM Talent t WHERE t.ratingAverage > 0")
    BigDecimal getAverageRating();
}
