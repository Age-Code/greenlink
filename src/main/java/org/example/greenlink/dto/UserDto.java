package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.User;

public class UserDto {

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

    // UserId Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UserIdResDto {
        Long userId;

        public static UserIdResDto toUserIdResDto(User user) {
            return UserIdResDto.builder().userId(user.getId()).build();
        }
    }

    // Login Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class LoginReqDto {
        public String username;
        public String password;
    }
}
