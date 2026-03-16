package org.example.greenlink.service.impl;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.User;
import org.example.greenlink.domain.UserPlant;
import org.example.greenlink.domain.UserPlantItem;
import org.example.greenlink.dto.UserPlantItemDto;
import org.example.greenlink.repository.UserPlantItemRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.UserPlantItemService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserPlantItemServiceimpl implements UserPlantItemService {
    private final UserPlantItemRepository userPlantItemRepository;
    private final UserRepository userRepository;

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
    public UserPlantItemDto.UpdateResDto updateItem(Long userPlantItemId, UserPlantItemDto.UpdateReqDto req, Long userId) {
        UserPlantItem upi = userPlantItemRepository.findByIdAndDeletedFalse(userPlantItemId)
                .orElseThrow(()->new IllegalArgumentException("userPlantItem not found"));

        if(!req.getUserPlantId().equals(upi.getUserPlant().getId())) {
            throw new IllegalStateException("userPlant's id is invalid");
        }

        if(upi.getItem().getType().)


    }
}
