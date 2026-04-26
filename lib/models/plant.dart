
class Plant {
  final int plantId;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;
  final int? growthDays;

  Plant({
    required this.plantId,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
    this.growthDays,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plantId'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      growthDays: json['growthDays'],
    );
  }
}

class UserPlant {
  final int userPlantId;
  final int plantId;
  final String plantName;
  final String nickname;
  final String status;
  final String? imageUrl;
  final String? plantedAt;
  final String? harvestedAt;
  final int? daysAfterPlanting;
  final int? remainingDays;
  final EquippedPot? equippedPot;

  UserPlant({
    required this.userPlantId,
    required this.plantId,
    required this.plantName,
    required this.nickname,
    required this.status,
    this.imageUrl,
    this.plantedAt,
    this.harvestedAt,
    this.daysAfterPlanting,
    this.remainingDays,
    this.equippedPot,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      userPlantId: json['userPlantId'] ?? 0,
      plantId: json['plantId'] ?? 0,
      plantName: json['plantName'] ?? '',
      nickname: json['nickname'] ?? '',
      status: json['status'] ?? 'GROWING',
      imageUrl: json['imageUrl'],
      plantedAt: json['plantedAt'],
      harvestedAt: json['harvestedAt'],
      daysAfterPlanting: json['daysAfterPlanting'],
      remainingDays: json['remainingDays'],
      equippedPot: json['equippedPot'] != null ? EquippedPot.fromJson(json['equippedPot']) : null,
    );
  }
}

class EquippedPot {
  final int userItemId;
  final int itemId;
  final String name;
  final String? imageUrl;

  EquippedPot({
    required this.userItemId,
    required this.itemId,
    required this.name,
    this.imageUrl,
  });

  factory EquippedPot.fromJson(Map<String, dynamic> json) {
    return EquippedPot(
      userItemId: json['userItemId'] ?? 0,
      itemId: json['itemId'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class CollectionPlant {
  final int plantId;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;
  final bool collected;
  final int harvestCount;
  final String? firstHarvestedAt;
  final List<dynamic>? harvestedPlants;

  CollectionPlant({
    required this.plantId,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
    required this.collected,
    required this.harvestCount,
    this.firstHarvestedAt,
    this.harvestedPlants,
  });

  factory CollectionPlant.fromJson(Map<String, dynamic> json) {
    return CollectionPlant(
      plantId: json['plantId'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      collected: json['collected'] ?? false,
      harvestCount: json['harvestCount'] ?? 0,
      firstHarvestedAt: json['firstHarvestedAt'],
      harvestedPlants: json['harvestedPlants'],
    );
  }
}
