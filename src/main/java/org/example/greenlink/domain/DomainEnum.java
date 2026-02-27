package org.example.greenlink.domain;

import lombok.NoArgsConstructor;

@NoArgsConstructor
public final class DomainEnum {

    public enum Difficulty {
        EASY,
        NORMAL,
        HARD
    }

    public enum LightPref {
        LOW,
        MEDIUM,
        HIGH
    }

    public enum Status {
        GROWING, // 키우는 중(기본)
        HARVESTABLE, // 수확 가능
        HARVESTED, // 수확 완료
        FAILED // 실패
    }

    public enum QuestType {
        DAILY,
        WEEKLY,
        ACHIEVEMENT
    }

    public enum State {
        ONGOING,
        COMPLETED,
        CLAIMED
    }

    public enum ItemType {
        POT,
        DECORATION,
        NUTRIENT,
        TITLE
    }
}