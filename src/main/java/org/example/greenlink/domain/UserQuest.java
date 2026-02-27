package org.example.greenlink.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
@Entity
public class UserQuest extends AuditingFields {
    Long progress;
    DomainEnum.State state;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quest_id", nullable = false)
    private Quest quest;

    protected UserQuest(){}
    private UserQuest(Long progress, DomainEnum.State state, User user, Quest quest) {
        this.progress = progress;
        this.state = state;
        this.user = user;
        this.quest = quest;
    }
    public static UserQuest of(Long progress, DomainEnum.State state, User user, Quest quest) {
        return new UserQuest(progress, state, user, quest);
    }
}
