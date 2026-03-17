package org.example.greenlink.repository;

import org.example.greenlink.domain.User;
import org.example.greenlink.domain.UserQuest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserQuestRepository extends JpaRepository<UserQuest, Long> {
    List<UserQuest> findByUserAndDeletedFalse(User user);
    Optional<UserQuest> findByIdAndDeletedFalse(Long userQuestId);
}
