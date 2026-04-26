
class Item {
  final int itemId;
  final String name;
  final String itemType;
  final String? description;
  final String? imageUrl;
  final int? linkedPlantId;
  
  Item({
    required this.itemId,
    required this.name,
    required this.itemType,
    this.description,
    this.imageUrl,
    this.linkedPlantId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'] ?? 0,
      name: json['name'] ?? '',
      itemType: json['itemType'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      linkedPlantId: json['linkedPlantId'],
    );
  }
}

class UserItem {
  final int userItemId;
  final String status;
  final int? userPlantId;
  final String? createdAt;

  UserItem({
    required this.userItemId,
    required this.status,
    this.userPlantId,
    this.createdAt,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      userItemId: json['userItemId'] ?? 0,
      status: json['status'] ?? 'OWNED',
      userPlantId: json['userPlantId'],
      createdAt: json['createdAt'],
    );
  }
}

class InventoryItem extends Item {
  final int ownedCount;
  final int usableCount;
  final int usedCount;
  final List<UserItem> items;

  InventoryItem({
    required int itemId,
    required String name,
    required String itemType,
    String? description,
    String? imageUrl,
    int? linkedPlantId,
    required this.ownedCount,
    required this.usableCount,
    required this.usedCount,
    required this.items,
  }) : super(
          itemId: itemId,
          name: name,
          itemType: itemType,
          description: description,
          imageUrl: imageUrl,
          linkedPlantId: linkedPlantId,
        );

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<UserItem> itemsList = list.map((i) => UserItem.fromJson(i)).toList();

    return InventoryItem(
      itemId: json['itemId'] ?? 0,
      name: json['name'] ?? '',
      itemType: json['itemType'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      linkedPlantId: json['linkedPlantId'],
      ownedCount: json['ownedCount'] ?? 0,
      usableCount: json['usableCount'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      items: itemsList,
    );
  }
}
