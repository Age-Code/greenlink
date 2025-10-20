package org.example.greenlink.domain.user;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.Setter;
import org.example.greenlink.domain.AuditingFields;
import org.example.greenlink.dto.admin.AdminUserDto;
import org.example.greenlink.dto.user.UserDto;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class User extends AuditingFields {
    String username;
    String password;
    String email;
    String university;
    String nickname;

    protected User(){}
    private User(String username, String password, String email, String university, String nickname) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.university = university;
        this.nickname = nickname;
    }
    public static User of(String username, String password, String email, String university, String nickname) { return new User(username, password, email, university, nickname); }

    public UserDto.SignupResDto toSignupResDto() { return UserDto.SignupResDto.builder().id(getId()).build(); }
    public AdminUserDto.CreateResDto toCreateResDto() { return AdminUserDto.CreateResDto.builder().id(getId()).build(); }
}
