package org.example.greenlink.repository;

import org.example.greenlink.domain.Quest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface QuestRepository extends JpaRepository<Quest, Long> {
    @Query("SELECT q FROM Quest q JOIN q.userQuests uq WHERE uq.user.id = :userId AND q.deleted = false")
    List<Quest> findAllByUserId(@Param("userId") Long userId);

    Optional<Quest> findByIdAndDeletedFalse(Long questId);
}
