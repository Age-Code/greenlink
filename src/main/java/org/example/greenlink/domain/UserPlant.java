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
    String potStyle;
    String decoration;
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
    private UserPlant(String nickname, String potStyle, String decoration, DomainEnum.Status status, LocalDate startDate, LocalDate expectedHarvestDate, LocalDate harvestDate, Double moisturePct, Double nutrientLevel, Double sunlightExposure, String lastPhotoUrl) {
        this.nickname = nickname;
        this.potStyle = potStyle;
        this.decoration = decoration;
        this.status = status;
        this.startDate = startDate;
        this.expectedHarvestDate = expectedHarvestDate;
        this.harvestDate = harvestDate;
        this.moisturePct = moisturePct;
        this.nutrientLevel = nutrientLevel;
        this.sunlightExposure = sunlightExposure;
        this.lastPhotoUrl = lastPhotoUrl;
    }
    public static UserPlant of(String nickname, String potStyle, String decoration, DomainEnum.Status status, LocalDate startDate, LocalDate expectedHarvestDate, LocalDate harvestDate, Double moisturePct, Double nutrientLevel, Double sunlightExposure, String lastPhotoUrl) {
        return new UserPlant(nickname, potStyle, decoration, status, startDate, expectedHarvestDate, harvestDate, moisturePct, nutrientLevel, sunlightExposure, lastPhotoUrl);
    }
}
