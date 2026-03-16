package org.example.greenlink.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
@Table(uniqueConstraints = @UniqueConstraint(columnNames={"user_plant_id","slot_key"}))
public class UserPlantItem extends AuditingFields {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_plant_id", nullable = true)
    private UserPlant userPlant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    protected UserPlantItem(){}
    private UserPlantItem(User user, UserPlant userPlant, Item item) {
        this.user = user;
        this.userPlant = userPlant;
        this.item = item;
    }

    public static UserPlantItem of(User user, UserPlant userPlant, Item item) {
        return new UserPlantItem(user, userPlant, item);
    }
}
