class CollectionItem {
  final int plantId;
  final String name;
  final String category;
  final String? imageUrl;
  final bool collected;
  final int harvestCount;
  final String? firstHarvestedAt;

  CollectionItem({
    required this.plantId,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.collected,
    required this.harvestCount,
    this.firstHarvestedAt,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      plantId: json['plantId'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      collected: json['collected'] as bool? ?? false,
      harvestCount: json['harvestCount'] as int? ?? 0,
      firstHarvestedAt: json['firstHarvestedAt'] as String?,
    );
  }
}

class CollectionDetail {
  final int plantId;
  final String name;
  final String category;
  final String? description;
  final String? imageUrl;
  final bool collected;
  final int harvestCount;
  final List<HarvestedPlant> harvestedPlants;

  CollectionDetail({
    required this.plantId,
    required this.name,
    required this.category,
    this.description,
    this.imageUrl,
    required this.collected,
    required this.harvestCount,
    required this.harvestedPlants,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) {
    return CollectionDetail(
      plantId: json['plantId'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      collected: json['collected'] as bool? ?? false,
      harvestCount: json['harvestCount'] as int? ?? 0,
      harvestedPlants: (json['harvestedPlants'] as List<dynamic>?)
              ?.map((e) => HarvestedPlant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HarvestedPlant {
  final int userPlantId;
  final String nickname;
  final String? imageUrl;
  final String? plantedAt;
  final String? harvestedAt;

  HarvestedPlant({
    required this.userPlantId,
    required this.nickname,
    this.imageUrl,
    this.plantedAt,
    this.harvestedAt,
  });

  factory HarvestedPlant.fromJson(Map<String, dynamic> json) {
    return HarvestedPlant(
      userPlantId: json['userPlantId'] as int,
      nickname: json['nickname'] as String,
      imageUrl: json['imageUrl'] as String?,
      plantedAt: json['plantedAt'] as String?,
      harvestedAt: json['harvestedAt'] as String?,
    );
  }
}
