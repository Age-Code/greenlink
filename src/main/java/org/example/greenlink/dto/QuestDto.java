package org.example.greenlink.dto;

import lombok.*;
import org.example.greenlink.domain.DomainEnum;
import org.example.greenlink.domain.Quest;


public class QuestDto {
    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class ListResDto {
        private Long questId;
        private String title;
        private DomainEnum.QuestType type;
        private DomainEnum.TargetType targetType;
        private int targetValue;
        private RewardItemDto rewardItem;

        public static ListResDto from(Quest q) {
            return ListResDto.builder()
                    .questId(q.getId())
                    .title(q.getTitle())
                    .type(q.getType())
                    .targetType(q.getTargetType())
                    .targetValue(q.getTargetValue())
                    .rewardItem(RewardItemDto.builder()
                            .itemId(q.getRewardItem().getId())
                            .name(q.getRewardItem().getName())
                            .type(q.getRewardItem().getType())
                            .build())
                    .build();
        }
    }

    // Detail Response Dto
    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class DetailResDto {
        private Long questId;
        private String title;
        private DomainEnum.QuestType type;
        private DomainEnum.TargetType targetType;
        private int targetValue;
        private String Description;
        private RewardItemDto rewardItem;

        public static DetailResDto from(Quest q) {
            return DetailResDto.builder()
                    .questId(q.getId())
                    .title(q.getTitle())
                    .type(q.getType())
                    .targetType(q.getTargetType())
                    .targetValue(q.getTargetValue())
                    .rewardItem(RewardItemDto.builder()
                            .itemId(q.getRewardItem().getId())
                            .name(q.getRewardItem().getName())
                            .type(q.getRewardItem().getType())
                            .build())
                    .build();
        }
    }

    @Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
    public static class RewardItemDto {
        private Long itemId;
        private String name;
        private DomainEnum.ItemType type;
    }
}
