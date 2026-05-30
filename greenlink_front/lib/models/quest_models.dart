class UserQuestSummary {
  final int userQuestId;
  final String questType;
  final String title;
  final String status;
  final int targetValue;
  final int progressValue;

  UserQuestSummary({
    required this.userQuestId, required this.questType, required this.title,
    required this.status, required this.targetValue, required this.progressValue,
  });

  factory UserQuestSummary.fromJson(Map<String, dynamic> json) => UserQuestSummary(
    userQuestId: json['userQuestId'] ?? 0,
    questType: json['questType'] ?? '',
    title: json['title'] ?? '',
    status: json['status'] ?? 'IN_PROGRESS',
    targetValue: json['targetValue'] ?? 0,
    progressValue: json['progressValue'] ?? 0,
  );
}

class UserQuestDetail {
  final int userQuestId;
  final String title;
  final String description;
  final String questType;
  final String targetType;
  final int targetValue;
  final int progressValue;
  final String status;
  final String? startedAt;
  final String? expiredAt;
  final RewardItem? rewardItem;

  UserQuestDetail({
    required this.userQuestId, required this.title, required this.description,
    required this.questType, required this.targetType, required this.targetValue,
    required this.progressValue, required this.status, this.startedAt,
    this.expiredAt, this.rewardItem,
  });

  factory UserQuestDetail.fromJson(Map<String, dynamic> json) => UserQuestDetail(
    userQuestId: json['userQuestId'] ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    questType: json['questType'] ?? '',
    targetType: json['targetType'] ?? '',
    targetValue: json['targetValue'] ?? 0,
    progressValue: json['progressValue'] ?? 0,
    status: json['status'] ?? 'IN_PROGRESS',
    startedAt: json['startedAt'],
    expiredAt: json['expiredAt'],
    rewardItem: json['rewardItem'] != null ? RewardItem.fromJson(json['rewardItem']) : null,
  );
}

class RewardItem {
  final int itemId;
  final String name;
  final String itemType;
  final int quantity;
  final String? imageUrl;

  RewardItem({
    required this.itemId, required this.name, required this.itemType,
    required this.quantity, this.imageUrl,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) => RewardItem(
    itemId: json['itemId'] ?? 0,
    name: json['name'] ?? '',
    itemType: json['itemType'] ?? '',
    quantity: json['quantity'] ?? 1,
    imageUrl: json['imageUrl'],
  );
}

class QuestRewardResponse {
  final RewardResult reward;
  final List<CreatedUserItem> createdItems;

  QuestRewardResponse({required this.reward, required this.createdItems});

  factory QuestRewardResponse.fromJson(Map<String, dynamic> json) => QuestRewardResponse(
    reward: RewardResult.fromJson(json['reward']),
    createdItems: (json['createdItems'] as List?)?.map((i) => CreatedUserItem.fromJson(i)).toList() ?? [],
  );
}

class RewardResult {
  final String itemName;
  final String itemType;
  final int quantity;

  RewardResult({required this.itemName, required this.itemType, required this.quantity});

  factory RewardResult.fromJson(Map<String, dynamic> json) => RewardResult(
    itemName: json['itemName'] ?? '',
    itemType: json['itemType'] ?? '',
    quantity: json['quantity'] ?? 1,
  );
}

class CreatedUserItem {
  final int userItemId;
  CreatedUserItem({required this.userItemId});
  factory CreatedUserItem.fromJson(Map<String, dynamic> json) => CreatedUserItem(
    userItemId: json['userItemId'] ?? 0,
  );
}
