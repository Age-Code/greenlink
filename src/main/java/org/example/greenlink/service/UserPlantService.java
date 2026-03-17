package org.example.greenlink.service;

import org.example.greenlink.dto.PlantDto;
import org.example.greenlink.dto.UserPlantDto;
import org.example.greenlink.security.PrincipalDetails;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@Service
public interface UserPlantService {
    UserPlantDto.UserPlantIdResDto create(UserPlantDto.CreateReqDto createReqDto, Long requestUserId);
    List<UserPlantDto.ListResDto> list(Long requestUserId);
    UserPlantDto.DetailResDto detail(Long userPlantId, Long requestUserId);
    UserPlantDto.UserPlantIdResDto update(Long userPlantId, UserPlantDto.UpdateReqDto updateReqDto, Long requestUserId);
    UserPlantDto.HarvestResDto harvest(Long userPlantId, Long requestUserId);
    UserPlantDto.WaterResDto water(Long userPlantId, Long requestUserId);
    UserPlantDto.LightResDto light(Long userPlantId, Long requestUserId);
}
