package org.example.greenlink.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EntityListeners(EntityListeners.class)
@Entity
public class RefreshToken extends AuditingFields{

    Long userId;

    @Column(unique = true)
    String token;

    protected RefreshToken() {}
    private RefreshToken(Long userId, String token) {
        this.userId = userId;
        this.token = token;
    }
    public static RefreshToken of(String token, Long userId) {
        return new RefreshToken(userId, token);
    }
}