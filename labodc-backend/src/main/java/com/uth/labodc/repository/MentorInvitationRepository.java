package com.uth.labodc.repository;

import com.uth.labodc.model.entity.MentorInvitation;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MentorInvitationRepository extends JpaRepository<MentorInvitation, Long> {
    List<MentorInvitation> findByMentorIdAndStatusOrderByReceivedDateDesc(Long mentorId, String status);

    List<MentorInvitation> findByMentorIdOrderByReceivedDateDesc(Long mentorId);

    @Query(value = "select * from mentor_invitations mi where mi.mentor_id = :mentorId and lower(cast(mi.status as text)) = 'pending' order by mi.received_date desc", nativeQuery = true)
    List<MentorInvitation> findPendingByMentorIdOrderByReceivedDateDesc(@Param("mentorId") Long mentorId);

    Optional<MentorInvitation> findByMentorIdAndProjectId(Long mentorId, Long projectId);
}
