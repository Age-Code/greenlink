package org.example.greenlink.repository;

import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.UserPlant;
import org.example.greenlink.domain.UserPlantItem;
import org.example.greenlink.dto.UserPlantItemDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface UserPlantItemRepository extends JpaRepository<UserPlantItem, Long> {
    List<UserPlantItem> findAllByUserIdAndDeletedFalse(Long userId);

    Optional<UserPlantItem> findByIdAndDeletedFalse(Long userPlantItemId);

    @Query("SELECT upi FROM UserPlantItem upi WHERE upi.userPlant = :plant " +
            "AND upi.item.type = :type AND upi.deleted = false")
    Optional<UserPlantItem> findByUserPlantAndItemType(UserPlant plant, ItemType type);

    Optional<UserPlantItem> findByUserPlantIdAndItemType(Long id, DomainEnum.ItemType type);
}
