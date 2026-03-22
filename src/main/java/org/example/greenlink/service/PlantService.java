package org.example.greenlink.service;

import org.example.greenlink.dto.PlantDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface PlantService {
    List<PlantDto.ListResDto> list();
    PlantDto.DetailResDto detail(Long plantId);
}
