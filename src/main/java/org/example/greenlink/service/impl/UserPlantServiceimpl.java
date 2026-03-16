package org.example.greenlink.service.impl;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.Plant;
import org.example.greenlink.domain.User;
import org.example.greenlink.domain.UserPlant;
import org.example.greenlink.dto.PlantDto;
import org.example.greenlink.dto.UserPlantDto;
import org.example.greenlink.mapper.PlantMapper;
import org.example.greenlink.repository.PlantRepository;
import org.example.greenlink.repository.UserPlantRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.UserPlantService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class UserPlantServiceimpl implements UserPlantService {

    final UserRepository userRepository;
    final PlantRepository plantRepository;
    final UserPlantRepository userPlantRepository;

    // 나의 식물 생성
    @Override
    public UserPlantDto.UserPlantIdResDto create(UserPlantDto.CreateReqDto createReqDto, Long requestUserId){
        User requestUser = userRepository.findById(requestUserId).orElseThrow(() -> new EntityNotFoundException("UserPlant Create Error: 존재하지 않는 User입니다."));
        Plant plant = plantRepository.findById(createReqDto.getPlantId()).orElseThrow(() -> new EntityNotFoundException("UserPlant Create Error: 존재하지 않는 Plant입니다."));

        return UserPlantDto.UserPlantIdResDto.from(userPlantRepository.save(UserPlant.of(createReqDto.getNickname(), DomainEnum.Status.GROWING, LocalDate.now(), LocalDate.now().plusDays(plant.getGrowthPeriodDays()), null, 0.0, 0.0, 0.0, null, requestUser, plant)));
    }

    // 나의 식물 목록 조회
    @Override
    public List<UserPlantDto.ListResDto> list(Long requestUserId) {
        User requestUser = userRepository.findById(requestUserId).orElseThrow(() -> new EntityNotFoundException("UserPlant List Error: 존재하지 않는 User입니다."));
        List<UserPlant> userPlantList = userPlantRepository.findByUser(requestUser);

        return userPlantList.stream().map(UserPlantDto.ListResDto::from).toList();
    }

    @Override
    public UserPlantDto.DetailResDto detail(Long userPlantId, Long requestUserId){

        return PlantDto.DetailResDto.toDetailResDto(plant);
    }

}
