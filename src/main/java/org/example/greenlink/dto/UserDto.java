package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.User;

public class UserDto {

    // Login Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class LoginReqDto {
        public String username;
        public String password;
    }

    // UserId Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UserIdResDto {
        Long userId;

        public static UserIdResDto from(User user) {
            return UserIdResDto.builder().userId(user.getId()).build();
        }
    }

    // Signup Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class SignupReqDto {
        public String username;
        public String password;
        public String email;
        public String nickname;
        public String phoneNumber;
        public String address;

        public User toEntity() { return User.of(getUsername(), getPassword(), getEmail(), getNickname(), getPhoneNumber(), getAddress()); }
    }

    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        public String username;
        public String email;
        public String nickname;
        public String phoneNumber;
        public String address;

        public static DetailResDto from(User user) {
            return DetailResDto.builder()
                    .username(user.getUsername())
                    .email(user.getEmail())
                    .nickname(user.getNickname())
                    .phoneNumber(user.getPhoneNumber())
                    .address(user.getAddress())
                    .build();
        }
    }

    // Update Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateReqDto {
        public String nickname;
        public String phoneNumber;
        public String address;
    }
}
