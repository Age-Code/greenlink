package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.UserPlantItem;


public class UserPlantItemDto {

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        private Long userPlantItemId;
        private Long itemId;
        private String name;
        private DomainEnum.ItemType type;
        private Long userPlantId;

        public static UserPlantItemDto.ListResDto from(UserPlantItem upi) {
            return ListResDto.builder()
                    .userPlantId(upi.getId())
                    .itemId(upi.getItem().getId())
                    .name(upi.getItem().getName())
                    .type(upi.getItem().getType())
                    .userPlantId(upi.getUserPlant().getId())
                    .build();
        }
    }

    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        private Long userPlantItemId;
        private Long itemId;
        private String name;
        private DomainEnum.ItemType type;
        private Long userPlantId;

        public static UserPlantItemDto.DetailResDto from(UserPlantItem upi) {
            return DetailResDto.builder()
                    .userPlantId(upi.getId())
                    .itemId(upi.getItem().getId())
                    .name(upi.getItem().getName())
                    .type(upi.getItem().getType())
                    .userPlantId(upi.getUserPlant().getId())
                    .build();
        }
    }

    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateReqDto {
        private Long userPlantId;
    }

    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateResDto {
        private Long userPlantItemId;
        private Long userPlantId;

        public static UserPlantItemDto.UpdateResDto from(UserPlantItem upi) {
            return UpdateResDto.builder()
                    .userPlantId(upi.getId())
                    .userPlantId(upi.getUserPlant().getId())
                    .build();
        }
    }
}
