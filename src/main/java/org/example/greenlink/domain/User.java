package org.example.greenlink.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.dto.admin.AdminUserDto;
import org.example.greenlink.dto.UserDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class User extends AuditingFields {
    String username;
    String password;
    String email;
    String nickname;
    String phoneNumber;
    String address;
    String role;

    protected User(){}
    private User(String username, String password, String email, String nickname, String phoneNumber, String address, String role) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.nickname = nickname;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.role = role;
    }
    public static User of(String username, String password, String email, String nickname, String phoneNumber, String address, String role) {
        return new User(username, password, email, nickname, phoneNumber, address, role); }

    public UserDto.SignupResDto toSignupResDto() { return UserDto.SignupResDto.builder().id(getId()).build(); }
    public AdminUserDto.CreateResDto toCreateResDto() { return AdminUserDto.CreateResDto.builder().id(getId()).build(); }
}
