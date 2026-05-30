package com.greenlink.greenlink.dto;

import com.greenlink.greenlink.domain.plant.Plant;
import lombok.*;

public class PlantDto {

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ListResDto {
        private Long plantId;
        private String name;
        private String category;
        private String imageUrl;

        public static ListResDto from(Plant plant) {
            return ListResDto.builder()
                    .plantId(plant.getId())
                    .name(plant.getName())
                    .category(plant.getCategory())
                    .imageUrl(plant.getImageUrl())
                    .build();
        }
    }

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DetailResDto {
        private Long plantId;
        private String name;
        private String category;
        private String description;
        private String imageUrl;
        private Integer growthDays;

        public static DetailResDto from(Plant plant) {
            return DetailResDto.builder()
                    .plantId(plant.getId())
                    .name(plant.getName())
                    .category(plant.getCategory())
                    .description(plant.getDescription())
                    .imageUrl(plant.getImageUrl())
                    .growthDays(plant.getGrowthDays())
                    .build();
        }
    }
}