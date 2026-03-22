package org.example.greenlink.service.impl;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.*;
import org.example.greenlink.dto.UserPlantItemDto;
import org.example.greenlink.repository.UserPlantItemRepository;
import org.example.greenlink.repository.UserPlantRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.UserPlantItemService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserPlantItemServiceimpl implements UserPlantItemService {
    private final UserPlantItemRepository userPlantItemRepository;
    private final UserRepository userRepository;
    private final UserPlantRepository userPlantRepository;

    @Override
    public List<UserPlantItemDto.ListResDto> list(Long reqUserId) {
        User reqUser = userRepository.findByIdAndDeletedFalse(reqUserId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        List<UserPlantItem> userPlantItems = userPlantItemRepository.findAllByUserIdAndDeletedFalse(reqUserId);

        return userPlantItems.stream().map(UserPlantItemDto.ListResDto::from).toList();
    }

    @Override
    public UserPlantItemDto.DetailResDto detailItem(Long userPlantItemId, Long reqUserId) {
        User reqUser = userRepository.findByIdAndDeletedFalse(reqUserId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        UserPlantItem userPlantItem = userPlantItemRepository.findByIdAndDeletedFalse(userPlantItemId)
                .orElseThrow(()->new IllegalArgumentException("userPlantItem not found"));

        return UserPlantItemDto.DetailResDto.from(userPlantItem);
    }

    @Override
    @Transactional
    public UserPlantItemDto.UpdateResDto updateItem(Long userPlantItemId, UserPlantItemDto.UpdateReqDto reqDto, Long reqUserId) {
        UserPlantItem userPlantItem = userPlantItemRepository.findByIdAndDeletedFalse(userPlantItemId)
                .orElseThrow(() -> new IllegalArgumentException("userPlantItem not found"));

        if (!userPlantItem.getUser().getId().equals(reqUserId)) {
            throw new IllegalStateException("This item does not belong to the user.");
        }

        UserPlant userPlant = userPlantRepository.findByIdAndDeletedFalse(reqDto.getUserPlantId())
                .orElseThrow(() -> new IllegalArgumentException("userPlant not found"));

        if (!userPlant.getUser().getId().equals(reqUserId)) {
            throw new IllegalStateException("You do not own this plant.");
        }

        DomainEnum.ItemType type = userPlantItem.getItem().getType();

        if (DomainEnum.ItemType.NUTRIENT == type) {
            userPlant.setNutrientLevel(userPlant.getNutrientLevel() + 1);
            userPlantItem.setDeleted(true);
            userPlantItem.setUserPlant(null);

        } else if (DomainEnum.ItemType.POT == type || DomainEnum.ItemType.DECORATION == type) {
            userPlantItemRepository.findByUserPlantIdAndItemType(userPlant.getId(), type)
                    .ifPresent(existingItem -> {
                        if (!existingItem.getId().equals(userPlantItem.getId())) {
                            existingItem.setUserPlant(null);
                        }
                    });

            userPlantItem.setUserPlant(userPlant);
        }

        return UserPlantItemDto.UpdateResDto.from(userPlantItem);
    }

}
