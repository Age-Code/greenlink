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
    UserPlantDto.UserPlantIdResDto create(UserPlantDto.CreateReqDto reqDto, Long reqUserId);
    List<UserPlantDto.ListResDto> list(Long reqUserId);
    UserPlantDto.DetailResDto detail(Long userPlantId, Long reqUserId);
    UserPlantDto.UserPlantIdResDto update(Long userPlantId, UserPlantDto.UpdateReqDto reqDto, Long reqUserId);
    UserPlantDto.HarvestResDto harvest(Long userPlantId, Long reqUserId);
    UserPlantDto.WaterResDto water(Long userPlantId, Long reqUserId);
    UserPlantDto.LightResDto light(Long userPlantId, Long reqUserId);
}
