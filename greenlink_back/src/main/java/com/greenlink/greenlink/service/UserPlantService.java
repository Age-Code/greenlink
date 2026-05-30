package com.greenlink.greenlink.service;

import com.greenlink.greenlink.domain.item.Item;
import com.greenlink.greenlink.domain.item.ItemType;
import com.greenlink.greenlink.domain.item.UserItem;
import com.greenlink.greenlink.domain.item.UserItemStatus;
import com.greenlink.greenlink.domain.plant.Plant;
import com.greenlink.greenlink.domain.plant.UserPlant;
import com.greenlink.greenlink.domain.plant.UserPlantStatus;
import com.greenlink.greenlink.domain.quest.TargetType;
import com.greenlink.greenlink.domain.user.User;
import com.greenlink.greenlink.dto.UserPlantDto;
import com.greenlink.greenlink.repository.UserItemRepository;
import com.greenlink.greenlink.repository.UserPlantRepository;
import com.greenlink.greenlink.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserPlantService {

    private final UserRepository userRepository;
    private final UserItemRepository userItemRepository;
    private final UserPlantRepository userPlantRepository;
    private final QuestProgressService questProgressService;

    @Transactional
    public UserPlantDto.CreateResDto createUserPlant(
            Long userId,
            UserPlantDto.CreateReqDto request
    ) {
        User user = findActiveUser(userId);

        UserItem seedUserItem = userItemRepository.findByIdAndUserAndDeletedFalse(
                        request.getUserItemId(),
                        user
                )
                .orElseThrow(() -> new IllegalArgumentException("사용할 씨앗 아이템을 찾을 수 없습니다."));

        validateSeedUserItem(seedUserItem);

        Item seedItem = seedUserItem.getItem();
        Plant linkedPlant = seedItem.getLinkedPlant();

        if (linkedPlant == null) {
            throw new IllegalStateException("씨앗 아이템에 연결된 식물이 없습니다.");
        }

        UserPlant userPlant = UserPlant.create(
                user,
                linkedPlant,
                request.getNickname()
        );

        UserPlant savedUserPlant = userPlantRepository.save(userPlant);

        seedUserItem.useSeed();

        return UserPlantDto.CreateResDto.from(savedUserPlant);
    }

    @Transactional
    public List<UserPlantDto.ListResDto> getUserPlants(Long userId, UserPlantStatus status) {
        User user = findActiveUser(userId);
        LocalDate today = LocalDate.now();

        List<UserPlant> userPlants;

        if (status == null) {
            userPlants = userPlantRepository.findAllByUserAndDeletedFalse(user);
        } else {
            userPlants = userPlantRepository.findAllByUserAndStatusAndDeletedFalse(user, status);
        }

        userPlants.forEach(userPlant -> userPlant.refreshHarvestableStatus(today));

        if (status != null) {
            userPlants = userPlants.stream()
                    .filter(userPlant -> userPlant.getStatus() == status)
                    .toList();
        }

        return userPlants.stream()
                .map(userPlant -> UserPlantDto.ListResDto.from(userPlant, today))
                .toList();
    }

    @Transactional
    public UserPlantDto.DetailResDto getUserPlant(Long userId, Long userPlantId) {
        User user = findActiveUser(userId);
        LocalDate today = LocalDate.now();

        UserPlant userPlant = userPlantRepository.findByIdAndUserAndDeletedFalse(userPlantId, user)
                .orElseThrow(() -> new IllegalArgumentException("식물을 찾을 수 없습니다."));

        userPlant.refreshHarvestableStatus(today);

        UserItem equippedPot = findEquippedPot(user, userPlant);

        return UserPlantDto.DetailResDto.of(userPlant, today, equippedPot);
    }

    @Transactional
    public UserPlantDto.UpdateNicknameResDto updateNickname(
            Long userId,
            Long userPlantId,
            UserPlantDto.UpdateNicknameReqDto request
    ) {
        User user = findActiveUser(userId);

        UserPlant userPlant = userPlantRepository.findByIdAndUserAndDeletedFalse(userPlantId, user)
                .orElseThrow(() -> new IllegalArgumentException("식물을 찾을 수 없습니다."));

        userPlant.updateNickname(request.getNickname());

        return UserPlantDto.UpdateNicknameResDto.from(userPlant);
    }

    @Transactional
    public UserPlantDto.HarvestResDto harvestUserPlant(Long userId, Long userPlantId) {
        User user = findActiveUser(userId);
        LocalDate today = LocalDate.now();

        UserPlant userPlant = userPlantRepository.findByIdAndUserAndDeletedFalse(userPlantId, user)
                .orElseThrow(() -> new IllegalArgumentException("식물을 찾을 수 없습니다."));

        userPlant.refreshHarvestableStatus(today);

        if (userPlant.getStatus() == UserPlantStatus.HARVESTED) {
            throw new IllegalStateException("이미 수확 완료된 식물입니다.");
        }

        if (!userPlant.isHarvestable(today)) {
            throw new IllegalStateException("아직 수확 가능한 날짜가 아닙니다.");
        }

        userPlant.harvest(LocalDateTime.now());

        questProgressService.increaseProgress(user, TargetType.HARVEST, 1);

        return UserPlantDto.HarvestResDto.from(userPlant);
    }

    private UserItem findEquippedPot(User user, UserPlant userPlant) {
        return userItemRepository
                .findFirstByUserAndItem_ItemTypeAndUserPlantAndStatusAndDeletedFalse(
                        user,
                        ItemType.POT,
                        userPlant,
                        UserItemStatus.EQUIPPED
                )
                .orElse(null);
    }

    private void validateSeedUserItem(UserItem userItem) {
        if (userItem.getStatus() != UserItemStatus.OWNED) {
            throw new IllegalStateException("보유 중인 씨앗만 사용할 수 있습니다.");
        }

        if (userItem.getItem().getItemType() != ItemType.SEED) {
            throw new IllegalStateException("씨앗 아이템만 식물 생성에 사용할 수 있습니다.");
        }

        if (userItem.isDeleted()) {
            throw new IllegalStateException("삭제된 아이템은 사용할 수 없습니다.");
        }
    }

    private User findActiveUser(Long userId) {
        return userRepository.findById(userId)
                .filter(user -> !user.isDeleted())
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }
}