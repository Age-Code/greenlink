package org.example.greenlink.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
@Table(
        uniqueConstraints = @UniqueConstraint(columnNames = {"code"})
)
public class Item extends AuditingFields {
    String code;
    String name;
    @Enumerated(EnumType.STRING)
    DomainEnum.ItemType type;
    String description;
    String imageUrl;

    @OneToMany(mappedBy = "rewardItem")
    private List<Quest> quests = new ArrayList<>();

    @OneToMany(mappedBy = "item")
    private List<UserPlantItem> userPlantItems = new ArrayList<>();

    protected Item(){}
    private Item(String code, String name, DomainEnum.ItemType type, String description, String imageUrl) {
        this.code = code;
        this.name = name;
        this.type = type;
        this.description = description;
        this.imageUrl = imageUrl;
    }
    public static Item of(String code, String name, DomainEnum.ItemType type, String description, String imageUrl) {
        return new Item(code, name, type, description, imageUrl); }
}
