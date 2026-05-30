package com.greenlink.greenlink.dto;

import com.greenlink.greenlink.domain.user.User;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.time.LocalDateTime;

public class UserDto {

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MeResDto {
        private Long userId;
        private String email;
        private String nickname;
        private String role;
        private LocalDateTime createdAt;

        public static MeResDto from(User user) {
            return MeResDto.builder()
                    .userId(user.getId())
                    .email(user.getEmail())
                    .nickname(user.getNickname())
                    .role(user.getRole().name())
                    .createdAt(user.getCreatedAt())
                    .build();
        }
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateNicknameReqDto {

        @NotBlank(message = "닉네임은 필수입니다.")
        @Size(max = 50, message = "닉네임은 50자 이하로 입력해야 합니다.")
        private String nickname;
    }

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateNicknameResDto {
        private Long userId;
        private String nickname;

        public static UpdateNicknameResDto from(User user) {
            return UpdateNicknameResDto.builder()
                    .userId(user.getId())
                    .nickname(user.getNickname())
                    .build();
        }
    }
}