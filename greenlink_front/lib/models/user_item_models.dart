class UserItemGroup {
  final int itemId;
  final String name;
  final String itemType;
  final String? description;
  final String? imageUrl;
  final int ownedCount;
  final int usableCount;
  final int usedCount;
  final List<UserItemDetail> items;

  UserItemGroup({
    required this.itemId, required this.name, required this.itemType,
    this.description, this.imageUrl, required this.ownedCount,
    required this.usableCount, required this.usedCount, required this.items,
  });

  factory UserItemGroup.fromJson(Map<String, dynamic> json) {
    return UserItemGroup(
      itemId: json['itemId'] ?? 0,
      name: json['name'] ?? '',
      itemType: json['itemType'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      ownedCount: json['ownedCount'] ?? 0,
      usableCount: json['usableCount'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      items: (json['items'] as List?)?.map((i) => UserItemDetail.fromJson(i)).toList() ?? [],
    );
  }
}

class UserItemDetail {
  final int userItemId;
  final String status;
  final int? userPlantId;

  UserItemDetail({required this.userItemId, required this.status, this.userPlantId});

  factory UserItemDetail.fromJson(Map<String, dynamic> json) => UserItemDetail(
    userItemId: json['userItemId'] ?? 0,
    status: json['status'] ?? 'OWNED',
    userPlantId: json['userPlantId'],
  );
}
