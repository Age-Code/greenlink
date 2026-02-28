package org.example.greenlink.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
@Table(
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "attend_date"})
)
public class Attend extends AuditingFields {
    LocalDate attendDate;
    int streakAfter;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    protected Attend(){}
    private Attend(LocalDate attendDate, int streakAfter, User user) {
        this.attendDate = attendDate;
        this.streakAfter = streakAfter;
        this.user = user;
    }
    public static Attend of(LocalDate attendDate, int streakAfter, User user) {
        return new Attend(attendDate, streakAfter, user);
    }
}
