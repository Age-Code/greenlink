package org.example.greenlink.service;

import org.example.greenlink.dto.PlantDto;
import org.example.greenlink.dto.QuestDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface QuestService {
    List<QuestDto.ListResDto> list(Long userId);
    QuestDto.DetailResDto detail(Long questId, Long userId);
}
