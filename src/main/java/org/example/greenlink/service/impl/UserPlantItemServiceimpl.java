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
    public List<UserPlantItemDto.ListResDto> list(Long userId) {
        User u = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        List<UserPlantItem> userPlantItems = userPlantItemRepository.findAllByUserIdAndDeletedFalse(userId);

        return userPlantItems.stream().map(UserPlantItemDto.ListResDto::from).toList();
    }

    @Override
    public UserPlantItemDto.DetailResDto detailItem(Long userPlantItemId, Long userId) {
        User u = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(()->new IllegalArgumentException("user not found"));

        UserPlantItem upi = userPlantItemRepository.findByIdAndDeletedFalse(userPlantItemId)
                .orElseThrow(()->new IllegalArgumentException("userPlantItem not found"));

        return UserPlantItemDto.DetailResDto.from(upi);
    }

    @Override
    @Transactional
    public UserPlantItemDto.UpdateResDto updateItem(Long userPlantItemId, UserPlantItemDto.UpdateReqDto req, Long userId) {
        UserPlantItem upi = userPlantItemRepository.findByIdAndDeletedFalse(userPlantItemId)
                .orElseThrow(() -> new IllegalArgumentException("userPlantItem not found"));

        if (!upi.getUser().getId().equals(userId)) {
            throw new IllegalStateException("This item does not belong to the user.");
        }

        UserPlant up = userPlantRepository.findByIdAndDeletedFalse(req.getUserPlantId())
                .orElseThrow(() -> new IllegalArgumentException("userPlant not found"));

        if (!up.getUser().getId().equals(userId)) {
            throw new IllegalStateException("You do not own this plant.");
        }

        DomainEnum.ItemType type = upi.getItem().getType();

        if (DomainEnum.ItemType.NUTRIENT == type) {
            up.setNutrientLevel(up.getNutrientLevel() + 1);
            upi.setDeleted(true);
            upi.setUserPlant(null);

        } else if (DomainEnum.ItemType.POT == type || DomainEnum.ItemType.DECORATION == type) {
            userPlantItemRepository.findByUserPlantIdAndItemType(up.getId(), type)
                    .ifPresent(existingItem -> {
                        if (!existingItem.getId().equals(upi.getId())) {
                            existingItem.setUserPlant(null);
                        }
                    });

            upi.setUserPlant(up);
        }

        return UserPlantItemDto.UpdateResDto.from(upi);
    }

}
