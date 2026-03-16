package org.example.greenlink.service.impl;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.Attend;
import org.example.greenlink.domain.User;
import org.example.greenlink.dto.AttendDto;
import org.example.greenlink.repository.AttendRepository;
import org.example.greenlink.repository.UserRepository;
import org.example.greenlink.service.AttendService;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class AttendServiceimpl implements AttendService {

    private final AttendRepository attendRepository;
    private final UserRepository userRepository;

    @Override
    public AttendDto.TodayResDto today(Long userId){
        User u = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        LocalDate today = LocalDate.now();
        LocalDate yesterday = today.minusDays(1);

        if (attendRepository.existsByUserAndAttendDate(u, today)) {
            throw new IllegalStateException("attend already exist");
        }

        int currentStreak = attendRepository.findByUserAndAttendDate(u, yesterday)
                .map(Attend::getStreakAfter)
                .orElse(0);

        Attend saved = attendRepository.save(
                Attend.of(today, currentStreak + 1, u)
        );

        return AttendDto.TodayResDto.from(saved);
    }


    @Override
    public AttendDto.ListResDto list(int year, int month, Long userId) {

        validateYearMonth(year, month);

        User u = userRepository.findByIdAndDeletedFalse(userId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        List<Attend> attends = attendRepository.findAllByUserAndAttendDateBetweenOrderByAttendDateAsc(u, startDate, endDate);

        List<LocalDate> attendDates = attends.stream()
                .map(Attend::getAttendDate)
                .toList();

        return AttendDto.ListResDto.builder()
                .dates(attendDates)
                .build();
    }

    private void validateYearMonth(int year, int month) {
        if (year < 1000 || year > 9999) {
            throw new IllegalArgumentException("연도는 4자리 숫자로 입력해야 합니다. (예: 2026)");
        }

        if (month < 1 || month > 12) {
            throw new IllegalArgumentException("월은 01에서 12 사이의 숫자여야 합니다.");
        }
    }

}
