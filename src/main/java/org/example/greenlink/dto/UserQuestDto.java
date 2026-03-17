package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.Quest;
import org.example.greenlink.domain.UserQuest;


public class UserQuestDto {

    // List Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        private Long userQuestId;
        private Long questId;
        private String title;
        private DomainEnum.TargetType targetType;
        private int targetValue;
        private int progress;
        private DomainEnum.State state;

        public static ListResDto from(UserQuest userQuest) {
            return ListResDto.builder()
                    .userQuestId(userQuest.getId())
                    .questId(userQuest.getQuest().getId())
                    .title(userQuest.getQuest().getTitle())
                    .targetType(userQuest.getQuest().getTargetType())
                    .targetValue(userQuest.getQuest().getTargetValue())
                    .progress(userQuest.getProgress())
                    .state(userQuest.getState())
                    .build();
        }
    }

    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        private Long userQuestId;
        private Long questId;
        private String title;
        private DomainEnum.TargetType targetType;
        private int targetValue;
        private int progress;
        private DomainEnum.State state;

        public static DetailResDto from(UserQuest userQuest) {
            return DetailResDto.builder()
                    .userQuestId(userQuest.getId())
                    .questId(userQuest.getQuest().getId())
                    .title(userQuest.getQuest().getTitle())
                    .targetType(userQuest.getQuest().getTargetType())
                    .targetValue(userQuest.getQuest().getTargetValue())
                    .progress(userQuest.getProgress())
                    .state(userQuest.getState())
                    .build();
        }
    }

    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ClaimResDto {
        private Long userQuestId;
        private Long questId;
        private DomainEnum.State state;
        private Reward reward;

        public static ClaimResDto from(UserQuest userQuest, Long userPlantItemId) {
            return ClaimResDto.builder()
                    .userQuestId(userQuest.getId())
                    .questId(userQuest.getQuest().getId())
                    .state(userQuest.getState())
                    .reward(Reward.builder()
                            .itemId(userQuest.getQuest().getRewardItem().getId())
                            .userPlantItemId(userPlantItemId)
                            .build())
                    .build();
        }
    }

    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class Reward {
        private Long itemId;
        private Long userPlantItemId;
    }
}