package org.example.greenlink.service.impl;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.apache.tomcat.websocket.AuthenticationException;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.Plant;
import org.example.greenlink.domain.User;
import org.example.greenlink.domain.UserPlant;
import org.example.greenlink.dto.PlantDto;
import org.example.greenlink.dto.UserPlantDto;
import org.example.greenlink.exception.NoMatchingDataException;
import org.example.greenlink.exception.NoPermissionException;
import org.example.greenlink.mapper.PlantMapper;
import org.example.greenlink.repository.PlantRepository;
import org.example.greenlink.repository.UserPlantRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.UserPlantService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

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

    // 나의 식물 상세 조회
    @Override
    public UserPlantDto.DetailResDto detail(Long userPlantId, Long requestUserId){
        UserPlant userPlant = userPlantRepository.findById(userPlantId).orElseThrow(() -> new EntityNotFoundException("UserPlant Detail Error: 존재하지 않는 UserPlant입니다."));
        if(!userPlant.getUser().getId().equals(requestUserId)){
            throw new NoPermissionException("UserPlant Detail Error: 접근 권한이 없습니다.");
        }

        return UserPlantDto.DetailResDto.from(userPlant);
    }

    @Override
    @Transactional
    public UserPlantDto.UserPlantIdResDto update(Long userPlantId, UserPlantDto.UpdateReqDto updateReqDto, Long requestUserId){
        UserPlant userPlant = userPlantRepository.findById(userPlantId).orElseThrow(() -> new EntityNotFoundException("UserPlant Update Error: 존재하지 않는 UserPlant입니다."));
        if(!userPlant.getUser().getId().equals(requestUserId)){
            throw new NoPermissionException("UserPlant Update Error: 접근 권한이 없습니다.");
        }

        if(StringUtils.hasText(updateReqDto.getNickname()) && !updateReqDto.getNickname().equals(userPlant.getNickname())){
            userPlant.setNickname(updateReqDto.getNickname());
        }

        return UserPlantDto.UserPlantIdResDto.from(userPlant);
    }

    @Override
    @Transactional
    public UserPlantDto.HarvestResDto harvest(Long userPlantId, Long requestUserId){
        UserPlant userPlant = userPlantRepository.findById(userPlantId).orElseThrow(() -> new EntityNotFoundException("UserPlant Harvest Error: 존재하지 않는 UserPlant입니다."));
        if(!userPlant.getUser().getId().equals(requestUserId)){
            throw new NoPermissionException("UserPlant Harvest Error: 접근 권한이 없습니다.");
        }

        if(!userPlant.getStatus().equals(DomainEnum.Status.HARVESTABLE)){
            throw new NoMatchingDataException("UserPlant Harvest Error: 아직 수확 가능한 상태가 아닙니다.");
        }

        userPlant.setStatus(DomainEnum.Status.HARVESTED);
        userPlant.setHarvestDate(LocalDate.now());

        return UserPlantDto.HarvestResDto.from(userPlant);
    }

    @Override
    @Transactional
    public UserPlantDto.WaterResDto water(Long userPlantId, Long requestUserId){
        UserPlant userPlant = userPlantRepository.findById(userPlantId).orElseThrow(() -> new EntityNotFoundException("UserPlant Water Error: 존재하지 않는 UserPlant입니다."));
        if(!userPlant.getUser().getId().equals(requestUserId)){
            throw new NoPermissionException("UserPlant Water Error: 접근 권한이 없습니다.");
        }

        userPlant.setMoisturePct(userPlant.getMoisturePct()+5);

        return UserPlantDto.WaterResDto.from(userPlant);
    }

    @Override
    @Transactional
    public UserPlantDto.LightResDto light(Long userPlantId, Long requestUserId){
        UserPlant userPlant = userPlantRepository.findById(userPlantId).orElseThrow(() -> new EntityNotFoundException("UserPlant Light Error: 존재하지 않는 UserPlant입니다."));
        if(!userPlant.getUser().getId().equals(requestUserId)){
            throw new NoPermissionException("UserPlant Light Error: 접근 권한이 없습니다.");
        }

        userPlant.setSunlightExposure(userPlant.getSunlightExposure()+5);

        return UserPlantDto.LightResDto.from(userPlant);
    }
}
