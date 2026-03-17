package org.example.greenlink.service.impl;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.Plant;
import org.example.greenlink.dto.PlantDto;
import org.example.greenlink.mapper.PlantMapper;
import org.example.greenlink.repository.PlantRepository;
import org.example.greenlink.service.PlantService;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class PlantServiceimpl implements PlantService {

    final PlantRepository plantRepository;
    final PlantMapper plantMapper;

    @Override
    public List<PlantDto.ListResDto> list(PlantDto.ListReqDto listReqDto){
        return plantMapper.list(listReqDto);
    }

    @Override
    public PlantDto.DetailResDto detail(Long plantId){
        Plant plant = plantRepository.findById(plantId).orElseThrow(() -> new EntityNotFoundException("Plant Detail Error"));

        return PlantDto.DetailResDto.from(plant);
    }

}
