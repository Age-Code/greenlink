package com.greenlink.greenlink.domain.iot;

import com.greenlink.greenlink.domain.plant.UserPlant;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(
        name = "grow_space_plant",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uq_grow_space_plant_user_plant",
                        columnNames = "user_plant_id"
                )
        }
)
public class GrowSpacePlant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 식물이 배치된 재배 공간
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grow_space_id", nullable = false)
    private GrowSpace growSpace;

    /**
     * 재배 공간에 연결된 사용자 식물
     */
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_plant_id", nullable = false)
    private UserPlant userPlant;

    @Column(nullable = false)
    private Boolean active;

    @Column(nullable = false)
    private boolean deleted;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime modifiedAt;

    @Builder
    private GrowSpacePlant(
            GrowSpace growSpace,
            UserPlant userPlant
    ) {
        this.growSpace = growSpace;
        this.userPlant = userPlant;
        this.active = true;
        this.deleted = false;
    }

    public static GrowSpacePlant connect(
            GrowSpace growSpace,
            UserPlant userPlant
    ) {
        return GrowSpacePlant.builder()
                .growSpace(growSpace)
                .userPlant(userPlant)
                .build();
    }

    public void disconnect() {
        this.active = false;
        this.deleted = true;
    }

    @PrePersist
    public void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.modifiedAt = now;

        if (this.active == null) {
            this.active = true;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}