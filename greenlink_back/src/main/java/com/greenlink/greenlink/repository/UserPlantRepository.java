package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.plant.Plant;
import com.greenlink.greenlink.domain.plant.UserPlant;
import com.greenlink.greenlink.domain.plant.UserPlantStatus;
import com.greenlink.greenlink.domain.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface UserPlantRepository extends JpaRepository<UserPlant, Long> {

    List<UserPlant> findAllByUserAndDeletedFalse(User user);

    List<UserPlant> findAllByUserAndStatusAndDeletedFalse(User user, UserPlantStatus status);

    Optional<UserPlant> findByIdAndUserAndDeletedFalse(Long id, User user);

    long countByUserAndPlantAndStatusAndDeletedFalse(
            User user,
            Plant plant,
            UserPlantStatus status
    );

    boolean existsByUserAndPlantAndStatusAndDeletedFalse(
            User user,
            Plant plant,
            UserPlantStatus status
    );

    List<UserPlant> findAllByUserAndPlantAndStatusAndDeletedFalse(
            User user,
            Plant plant,
            UserPlantStatus status
    );

    List<UserPlant> findAllByUserAndPlantAndStatusAndDeletedFalseOrderByHarvestedAtAsc(
            User user,
            Plant plant,
            UserPlantStatus status
    );

    Optional<UserPlant> findFirstByUserAndStatusInAndDeletedFalseOrderByCreatedAtDesc(
            User user,
            Collection<UserPlantStatus> statuses
    );

    Optional<UserPlant> findFirstByUserAndDeletedFalseOrderByCreatedAtDesc(User user);

    Optional<UserPlant> findByIdAndDeletedFalse(Long id);
}