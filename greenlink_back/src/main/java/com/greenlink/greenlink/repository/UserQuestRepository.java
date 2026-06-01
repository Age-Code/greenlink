package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.quest.Quest;
import com.greenlink.greenlink.domain.quest.QuestType;
import com.greenlink.greenlink.domain.quest.UserQuest;
import com.greenlink.greenlink.domain.quest.UserQuestStatus;
import com.greenlink.greenlink.domain.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

// UserQuestRepository — JPA 데이터 접근
public interface UserQuestRepository extends JpaRepository<UserQuest, Long> {

    // find By Id And User And Deleted False 조회 — JPA query method
    Optional<UserQuest> findByIdAndUserAndDeletedFalse(Long id, User user);

    // find All By User And Deleted False 조회 — JPA query method
    List<UserQuest> findAllByUserAndDeletedFalse(User user);

    // exists By User And Quest And Deleted False 존재 여부 조회 — JPA query method
    boolean existsByUserAndQuestAndDeletedFalse(User user, Quest quest);

    // find All By User And Quest Quest Type And Deleted False 조회 — JPA query method
    List<UserQuest> findAllByUserAndQuest_QuestTypeAndDeletedFalse(
            User user,
            QuestType questType
    );

    // find All By User And Status And Deleted False 조회 — JPA query method
    List<UserQuest> findAllByUserAndStatusAndDeletedFalse(
            User user,
            UserQuestStatus status
    );

    // find All By User And Quest Quest Type And Status And Deleted False 조회 — JPA query method
    List<UserQuest> findAllByUserAndQuest_QuestTypeAndStatusAndDeletedFalse(
            User user,
            QuestType questType,
            UserQuestStatus status
    );

    // find By User And Quest And Started At And Deleted False 조회 — JPA query method
    Optional<UserQuest> findByUserAndQuestAndStartedAtAndDeletedFalse(
            User user,
            Quest quest,
            LocalDateTime startedAt
    );

    // exists By User And Quest And Started At And Deleted False 존재 여부 조회 — JPA query method
    boolean existsByUserAndQuestAndStartedAtAndDeletedFalse(
            User user,
            Quest quest,
            LocalDateTime startedAt
    );

    // find First By User And Quest And Deleted False 조회 — JPA query method
    Optional<UserQuest> findFirstByUserAndQuestAndDeletedFalse(
            User user,
            Quest quest
    );
}
