package com.greenlink.greenlink.domain.iot;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "grow_space")
public class GrowSpace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 재배 공간 이름
     * 예: 캡스톤 재배 공간, 연구실 재배 공간
     */
    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 500)
    private String description;

    @Column(nullable = false)
    private Boolean active;

    @Column(nullable = false)
    private boolean deleted;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime modifiedAt;

    @Builder
    private GrowSpace(
            String name,
            String description
    ) {
        this.name = name;
        this.description = description;
        this.active = true;
        this.deleted = false;
    }

    public static GrowSpace create(
            String name,
            String description
    ) {
        return GrowSpace.builder()
                .name(name)
                .description(description)
                .build();
    }

    public void updateInfo(
            String name,
            String description
    ) {
        this.name = name;
        this.description = description;
    }

    public void deactivate() {
        this.active = false;
    }

    public void activate() {
        this.active = true;
    }

    public void delete() {
        this.deleted = true;
        this.active = false;
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