package org.example.greenlink.domain;

import lombok.NoArgsConstructor;

@NoArgsConstructor
public final class DomainEnum {

    public enum Difficulty {
        EASY,
        NORMAL,
        HARD
    }

    public enum lightPref {
        LOW,
        MEDIUM,
        HIGH
    }
}