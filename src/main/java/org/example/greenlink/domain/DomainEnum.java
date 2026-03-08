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
        GROWING,
        HARVESTABLE,
        HARVESTED,
        FAILED
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