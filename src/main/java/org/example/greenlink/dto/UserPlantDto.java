package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.Plant;
import org.example.greenlink.domain.UserPlant;

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
        public Long plantId;
        public String name;
        public String category;
        public String difficulty;
        public String imageUrl;
    }

    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        public String name;
        public String description;
        public String category;
        public DomainEnum.Difficulty difficulty;
        public int growthPeriodDays;
        DomainEnum.LightPref lightPref;
        public int waterPreMlPerDay;
        public String imageUrl;
        public String unlockCondition;

        public static DetailResDto from(Plant plant){
            return DetailResDto.builder()
                    .name(plant.getName())
                    .description(plant.getDescription())
                    .category(plant.getCategory())
                    .difficulty(plant.getDifficulty())
                    .growthPeriodDays(plant.getGrowthPeriodDays())
                    .lightPref(plant.getLightPref())
                    .waterPreMlPerDay(plant.getWaterPrefMlPerDay())
                    .imageUrl(plant.getImageUrl())
                    .unlockCondition(plant.getUnlockCondition())
                    .build();
        }
    }

    // Update Request Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class UpdateReqDto {
        public String nickname;
        public String phoneNumber;
        public String address;
    }
}
