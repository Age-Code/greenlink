package org.example.greenlink.service;

import org.example.greenlink.dto.AttendDto;
import org.example.greenlink.dto.PlantDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface AttendService {
    AttendDto.TodayResDto today(Long userId);
    AttendDto.ListResDto list(int year, int month, Long userId);
}
