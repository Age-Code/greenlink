package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.Plant;
import org.example.greenlink.domain.UserPlant;

import java.time.LocalDate;
import java.util.List;

public class UserPlantDto {

    // UserPlantId Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UserPlantIdResDto {
        public Long userPlantId;

        public static UserPlantIdResDto from(UserPlant userPlant){
            return builder().userPlantId(userPlant.getId()).build();
        }
    }

    // Create Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class CreateReqDto {
        public Long plantId;
        public String nickname;
    }

    // List Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListReqDto {
        public String keyword;
        public List<String> categoryList;
        public List<String> difficultyList;
    }

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        public Long userPlantId;
        public Long plantId;
        public String plantName;
        public String nickname;
        public DomainEnum.Status status;
        public LocalDate expectedHarvestDate;
        public Double moisturePct;
        public Double nutrientLevel;
        public Double sunlightExposure;
        public String lastPhotoUrl;

        public static ListResDto from(UserPlant userPlant){
            return ListResDto.builder()
                    .userPlantId(userPlant.getId())
                    .plantId(userPlant.getPlant().getId())
                    .plantName(userPlant.getPlant().getName())
                    .nickname(userPlant.getNickname())
                    .status(userPlant.getStatus())
                    .expectedHarvestDate(userPlant.getExpectedHarvestDate())
                    .moisturePct(userPlant.getMoisturePct())
                    .nutrientLevel(userPlant.getNutrientLevel())
                    .sunlightExposure(userPlant.getSunlightExposure())
                    .lastPhotoUrl(userPlant.getLastPhotoUrl())
                    .build();
        }
    }

    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        public Long userPlantId;
        public Long plantId;
        public String plantName;
        public String plantCategory;
        public String nickname;
        public DomainEnum.Status status;
        public LocalDate startDate;
        public LocalDate expectedHarvestDate;
        public LocalDate harvestDate;
        public Double moisturePct;
        public Double nutrientLevel;
        public Double sunlightExposure;
        public String lastPhotoUrl;

        public static DetailResDto from(UserPlant userPlant){
            return DetailResDto.builder()
                    .userPlantId(userPlant.getId())
                    .plantId(userPlant.getPlant().getId())
                    .plantName(userPlant.getPlant().getName())
                    .plantName(userPlant.getPlant().getCategory())
                    .nickname(userPlant.getNickname())
                    .status(userPlant.getStatus())
                    .startDate(userPlant.getStartDate())
                    .expectedHarvestDate(userPlant.getExpectedHarvestDate())
                    .harvestDate(userPlant.getHarvestDate())
                    .moisturePct(userPlant.getMoisturePct())
                    .nutrientLevel(userPlant.getNutrientLevel())
                    .sunlightExposure(userPlant.getSunlightExposure())
                    .lastPhotoUrl(userPlant.getLastPhotoUrl())
                    .build();
        }

    }

    // Update Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateReqDto {
        public String nickname;
    }

    // Harvest Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class HarvestResDto {
        public Long userPlantId;
        public DomainEnum.Status status;
        public LocalDate harvestDate;

        public static HarvestResDto from(UserPlant userPlant){
            return builder()
                    .userPlantId(userPlant.getId())
                    .status(userPlant.getStatus())
                    .harvestDate(userPlant.getHarvestDate())
                    .build();
        }
    }

    // Water Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class WaterResDto {
        public Long userPlantId;
        public Double moisturePct;

        public static WaterResDto from(UserPlant userPlant){
            return builder()
                    .userPlantId(userPlant.getId())
                    .moisturePct(userPlant.getMoisturePct())
                    .build();
        }
    }

    // Light Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class LightResDto {
        public Long userPlantId;
        public Double sunlightExposure;

        public static LightResDto from(UserPlant userPlant){
            return builder()
                    .userPlantId(userPlant.getId())
                    .sunlightExposure(userPlant.getSunlightExposure())
                    .build();
        }
    }
}
