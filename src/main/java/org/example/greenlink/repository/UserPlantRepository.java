package org.example.greenlink.repository;

import org.example.greenlink.domain.Plant;
import org.example.greenlink.domain.User;
import org.example.greenlink.domain.UserPlant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserPlantRepository extends JpaRepository<UserPlant, Long> {
    List<UserPlant> findByUser(User user);
    Optional<UserPlant> findByIdAndDeletedFalse(Long userPlantId);
}
