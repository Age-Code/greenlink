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
public class Quest extends AuditingFields {
    String title;
    String description;
    @Enumerated(EnumType.STRING)
    DomainEnum.QuestType type;
    String targetType;
    int targetValue;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reward_item_id")
    private Item rewardItem;

    @OneToMany(mappedBy = "quest")
    private List<UserQuest> userQuests = new ArrayList<>();

    protected Quest(){}
    private Quest(String title, String description, DomainEnum.QuestType type, String targetType, int targetValue, Item rewardItem) {
        this.title = title;
        this.description = description;
        this.type = type;
        this.targetType = targetType;
        this.targetValue = targetValue;
        this.rewardItem = rewardItem;
    }
    public static Quest of(String title, String description, DomainEnum.QuestType type, String targetType, int targetValue, Item rewardItem) {
        return new Quest(title, description, type, targetType, targetValue, rewardItem);
    }
}
