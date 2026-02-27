package org.example.greenlink.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.OneToMany;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.util.ArrayList;
import java.util.List;

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

    @OneToMany(mappedBy = "user")
    private List<Attend> attends = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<UserPlant> userPlants = new ArrayList<>();

    @OneToMany(mappedBy = "user")
    private List<UserQuest> userQuests = new ArrayList<>();

    protected User(){}
    private User(String username, String password, String email, String nickname, String phoneNumber, String address) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.nickname = nickname;
        this.phoneNumber = phoneNumber;
        this.address = address;
    }
    public static User of(String username, String password, String email, String nickname, String phoneNumber, String address) {
        return new User(username, password, email, nickname, phoneNumber, address); }
}
