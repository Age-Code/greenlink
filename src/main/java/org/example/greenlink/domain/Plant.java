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
public class Plant extends AuditingFields {
    String name;
    String description;
    String category;
    @Enumerated(EnumType.STRING)
    DomainEnum.Difficulty difficulty;
    int growthPeriodDays;
    @Enumerated(EnumType.STRING)
    DomainEnum.LightPref lightPref;
    int waterPrefMlPerDay;
    String imageUrl;
    String unlockCondition;

    @OneToMany(mappedBy = "plant")
    private List<UserPlant> userPlants = new ArrayList<>();

    protected Plant(){}
    private Plant(String name, String description, String category, DomainEnum.Difficulty difficulty, int growthPeriodDays, DomainEnum.LightPref lightPref, int waterPrefMlPerDay, String imageUrl, String unlockCondition) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.difficulty = difficulty;
        this.growthPeriodDays = growthPeriodDays;
        this.lightPref = lightPref;
        this.waterPrefMlPerDay = waterPrefMlPerDay;
        this.imageUrl = imageUrl;
        this.unlockCondition = unlockCondition;
    }
    public static Plant of(String name, String description, String category, DomainEnum.Difficulty difficulty, int growthPeriodDays, DomainEnum.LightPref lightPref, int waterPrefMlPerDay, String imageUrl, String unlockCondition) {
        return new Plant(name, description, category, difficulty, growthPeriodDays, lightPref, waterPrefMlPerDay, imageUrl, unlockCondition); }
}
