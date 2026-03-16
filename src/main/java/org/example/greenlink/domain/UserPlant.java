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
public class UserPlant extends AuditingFields {
    String nickname;
    @Enumerated(EnumType.STRING)
    DomainEnum.Status status;
    LocalDate startDate;
    LocalDate expectedHarvestDate;
    LocalDate harvestDate;
    Double moisturePct;
    Double nutrientLevel;
    Double sunlightExposure;
    String lastPhotoUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plant_id", nullable = false)
    private Plant plant;

    @OneToMany(mappedBy = "userPlant")
    private List<UserPlantItem> userPlantItems = new ArrayList<>();

    protected UserPlant(){}
    private UserPlant(String nickname, DomainEnum.Status status, LocalDate startDate, LocalDate expectedHarvestDate, LocalDate harvestDate, Double moisturePct, Double nutrientLevel, Double sunlightExposure, String lastPhotoUrl, User user, Plant plant) {
        this.nickname = nickname;
        this.status = status;
        this.startDate = startDate;
        this.expectedHarvestDate = expectedHarvestDate;
        this.harvestDate = harvestDate;
        this.moisturePct = moisturePct;
        this.nutrientLevel = nutrientLevel;
        this.sunlightExposure = sunlightExposure;
        this.lastPhotoUrl = lastPhotoUrl;
        this.user = user;
        this.plant = plant;
    }
    public static UserPlant of(String nickname, DomainEnum.Status status, LocalDate startDate, LocalDate expectedHarvestDate, LocalDate harvestDate, Double moisturePct, Double nutrientLevel, Double sunlightExposure, String lastPhotoUrl, User user, Plant plant) {
        return new UserPlant(nickname, status, startDate, expectedHarvestDate, harvestDate, moisturePct, nutrientLevel, sunlightExposure, lastPhotoUrl, user, plant);
    }
}
