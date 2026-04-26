class UserQuest {
  final int userQuestId;
  final int questId;
  final String title;
  final String questType;
  final String targetType;
  final int targetValue;
  final int progressValue;
  final String status;
  final String? startedAt;
  final String? expiredAt;

  UserQuest({
    required this.userQuestId,
    required this.questId,
    required this.title,
    required this.questType,
    required this.targetType,
    required this.targetValue,
    required this.progressValue,
    required this.status,
    this.startedAt,
    this.expiredAt,
  });

  factory UserQuest.fromJson(Map<String, dynamic> json) {
    return UserQuest(
      userQuestId: json['userQuestId'] as int,
      questId: json['questId'] as int,
      title: json['title'] as String,
      questType: json['questType'] as String,
      targetType: json['targetType'] as String,
      targetValue: json['targetValue'] as int? ?? 0,
      progressValue: json['progressValue'] as int? ?? 0,
      status: json['status'] as String,
      startedAt: json['startedAt'] as String?,
      expiredAt: json['expiredAt'] as String?,
    );
  }
}

class QuestRewardResponse {
  final int userQuestId;
  final String status;
  final QuestReward reward;
  final List<CreatedUserItem> createdUserItems;

  QuestRewardResponse({
    required this.userQuestId,
    required this.status,
    required this.reward,
    required this.createdUserItems,
  });

  factory QuestRewardResponse.fromJson(Map<String, dynamic> json) {
    return QuestRewardResponse(
      userQuestId: json['userQuestId'] as int,
      status: json['status'] as String,
      reward: QuestReward.fromJson(json['reward'] as Map<String, dynamic>),
      createdUserItems: (json['createdUserItems'] as List<dynamic>?)
              ?.map((e) => CreatedUserItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuestReward {
  final int itemId;
  final String itemName;
  final String itemType;
  final int quantity;

  QuestReward({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.quantity,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) {
    return QuestReward(
      itemId: json['itemId'] as int,
      itemName: json['itemName'] as String,
      itemType: json['itemType'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class CreatedUserItem {
  final int userItemId;
  final int itemId;
  final String status;

  CreatedUserItem({
    required this.userItemId,
    required this.itemId,
    required this.status,
  });

  factory CreatedUserItem.fromJson(Map<String, dynamic> json) {
    return CreatedUserItem(
      userItemId: json['userItemId'] as int,
      itemId: json['itemId'] as int,
      status: json['status'] as String,
    );
  }
}

class UserQuestDetail {
  final int userQuestId;
  final int questId;
  final String title;
  final String? description;
  final String questType;
  final String targetType;
  final int targetValue;
  final int progressValue;
  final String status;
  final String? startedAt;
  final String? expiredAt;
  final String? createdAt;
  final String? modifiedAt;
  final RewardItem? rewardItem;
  final int rewardQuantity;

  UserQuestDetail({
    required this.userQuestId,
    required this.questId,
    required this.title,
    this.description,
    required this.questType,
    required this.targetType,
    required this.targetValue,
    required this.progressValue,
    required this.status,
    this.startedAt,
    this.expiredAt,
    this.createdAt,
    this.modifiedAt,
    this.rewardItem,
    required this.rewardQuantity,
  });

  factory UserQuestDetail.fromJson(Map<String, dynamic> json) {
    return UserQuestDetail(
      userQuestId: json['userQuestId'] as int,
      questId: json['questId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      questType: json['questType'] as String,
      targetType: json['targetType'] as String,
      targetValue: json['targetValue'] as int? ?? 0,
      progressValue: json['progressValue'] as int? ?? 0,
      status: json['status'] as String,
      startedAt: json['startedAt'] as String?,
      expiredAt: json['expiredAt'] as String?,
      createdAt: json['createdAt'] as String?,
      modifiedAt: json['modifiedAt'] as String?,
      rewardItem: json['rewardItem'] != null ? RewardItem.fromJson(json['rewardItem']) : null,
      rewardQuantity: json['rewardQuantity'] as int? ?? 1,
    );
  }
}

class RewardItem {
  final int itemId;
  final String name;
  final String itemType;
  final String? imageUrl;

  RewardItem({
    required this.itemId,
    required this.name,
    required this.itemType,
    this.imageUrl,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      itemId: json['itemId'] as int,
      name: json['name'] as String,
      itemType: json['itemType'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
