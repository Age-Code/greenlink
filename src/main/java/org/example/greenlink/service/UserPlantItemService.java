package org.example.greenlink.service;

import org.example.greenlink.dto.UserPlantItemDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserPlantItemService {
    List<UserPlantItemDto.ListResDto> list(Long userId);
    UserPlantItemDto.DetailResDto detailItem(Long userPlantItemId, Long userId);
    UserPlantItemDto.UpdateResDto updateItem(Long userPlantItemId, UserPlantItemDto.UpdateReqDto req, Long userId);
}
