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
public class UserPlantItem extends AuditingFields {
    Long quantity;
    Boolean equipped;
    LocalDateTime appliedAt;
    LocalDateTime expiresAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_plant_id", nullable = false)
    private UserPlant userPlant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    protected UserPlantItem(){}
    private UserPlantItem(Long quantity, Boolean equipped, LocalDateTime appliedAt, LocalDateTime expiresAt, UserPlant userPlant, Item item) {
        this.quantity = quantity;
        this.equipped = equipped;
        this.appliedAt = appliedAt;
        this.expiresAt = expiresAt;
        this.userPlant = userPlant;
        this.item = item;
    }
    public static UserPlantItem of(Long quantity, Boolean equipped, LocalDateTime appliedAt, LocalDateTime expiresAt, UserPlant userPlant, Item item) {
        return new UserPlantItem(quantity, equipped, appliedAt, expiresAt, userPlant, item);
    }
}
