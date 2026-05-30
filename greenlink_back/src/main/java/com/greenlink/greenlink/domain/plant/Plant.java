package com.greenlink.greenlink.domain.plant;

import com.greenlink.greenlink.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "plant")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Plant extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 식물 이름: 바질, 민트, 깻잎 등
    @Column(nullable = false, length = 50)
    private String name;

    // 식물 카테고리: HERB, VEGETABLE, FLOWER 등
    @Column(nullable = false, length = 30)
    private String category;

    // 식물 설명
    @Column(columnDefinition = "TEXT")
    private String description;

    // 식물 기본 이미지
    @Column(name = "image_url", length = 500)
    private String imageUrl;

    // 수확 가능 상태까지 필요한 기본 성장 일수
    @Column(name = "growth_days", nullable = false)
    private Integer growthDays;

    private Plant(String name, String category, String description, String imageUrl, Integer growthDays) {
        this.name = name;
        this.category = category;
        this.description = description;
        this.imageUrl = imageUrl;
        this.growthDays = growthDays;
    }

    public static Plant create(String name, String category, String description, String imageUrl, Integer growthDays) {
        return new Plant(name, category, description, imageUrl, growthDays);
    }

    public void update(String name, String category, String description, String imageUrl, Integer growthDays) {
        this.name = name;
        this.category = category;
        this.description = description;
        this.imageUrl = imageUrl;
        this.growthDays = growthDays;
    }
}