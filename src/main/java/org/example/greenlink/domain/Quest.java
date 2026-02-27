package org.example.greenlink.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class Quest extends AuditingFields {
    String title;
    String description;
    DomainEnum.QuestType type;
    String targetType;
    Long targetValue;

    @OneToMany(mappedBy = "quest")
    private List<Quest> quests = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reward_item_id", nullable = true)
    private User rewardItem;

    protected Quest(){}
    private Quest(String title, String description, DomainEnum.QuestType type, Long targetValue) {
        this.title = title;
        this.description = description;
        this.type = type;
        this.targetValue = targetValue;
    }
    public static Quest of(String title, String description, DomainEnum.QuestType type, Long targetValue) {
        return new Quest(title, description, type, targetValue);
    }
}
