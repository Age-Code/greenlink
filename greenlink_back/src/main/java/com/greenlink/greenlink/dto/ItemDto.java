package com.greenlink.greenlink.dto;

import com.greenlink.greenlink.domain.item.Item;
import lombok.*;

public class ItemDto {

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ListResDto {
        private Long itemId;
        private String name;
        private String itemType;
        private String imageUrl;

        public static ListResDto from(Item item) {
            return ListResDto.builder()
                    .itemId(item.getId())
                    .name(item.getName())
                    .itemType(item.getItemType().name())
                    .imageUrl(item.getImageUrl())
                    .build();
        }
    }

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DetailResDto {
        private Long itemId;
        private String name;
        private String itemType;
        private String description;
        private String imageUrl;
        private Long linkedPlantId;

        public static DetailResDto from(Item item) {
            Long linkedPlantId = item.getLinkedPlant() == null
                    ? null
                    : item.getLinkedPlant().getId();

            return DetailResDto.builder()
                    .itemId(item.getId())
                    .name(item.getName())
                    .itemType(item.getItemType().name())
                    .description(item.getDescription())
                    .imageUrl(item.getImageUrl())
                    .linkedPlantId(linkedPlantId)
                    .build();
        }
    }
}