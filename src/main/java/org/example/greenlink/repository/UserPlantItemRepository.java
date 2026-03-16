package org.example.greenlink.repository;

import org.example.greenlink.domain.UserPlantItem;
import org.example.greenlink.dto.UserPlantItemDto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserPlantItemRepository extends JpaRepository<UserPlantItem, Long> {
    List<UserPlantItem> findAllByUserIdAndDeletedFalse(Long userId);

    Optional<UserPlantItem> findByIdAndDeletedFalse(Long userPlantItemId);
}
