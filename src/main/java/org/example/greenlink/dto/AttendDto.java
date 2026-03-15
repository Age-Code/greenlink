package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.Attend;

import java.time.LocalDate;
import java.util.List;

public class AttendDto {
    //Today Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class TodayResDto {
        private LocalDate attendDate;
        private int streakAfter;

        public static TodayResDto from(Attend attend) {
            return TodayResDto.builder()
                    .attendDate(attend.getAttendDate())
                    .streakAfter(attend.getStreakAfter())
                    .build();
        }
    }

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        private List<LocalDate> dates;
    }
}
