package com.uth.labodc.repository;

import com.uth.labodc.model.entity.Mentor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface MentorRepository extends JpaRepository<Mentor, Long> {

    Optional<Mentor> findByUserId(Long userId);

    boolean existsByUserId(Long userId);
    
    long countByAvailable(Boolean available);
    
    @Query("SELECT AVG(m.ratingAverage) FROM Mentor m WHERE m.ratingAverage > 0")
    BigDecimal getAverageRating();
}
