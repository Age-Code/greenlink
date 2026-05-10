class HomeResponse {
  final HomeUser user;
  final HomeUserPlant? mainUserPlant;
  final Map<String, dynamic>? attendanceSummary;
  final Map<String, dynamic>? questSummary;

  HomeResponse({required this.user, this.mainUserPlant, this.attendanceSummary, this.questSummary});

  factory HomeResponse.fromJson(Map<String, dynamic> json) => HomeResponse(
    user: HomeUser.fromJson(json['user']),
    mainUserPlant: json['mainUserPlant'] != null ? HomeUserPlant.fromJson(json['mainUserPlant']) : null,
    attendanceSummary: json['attendanceSummary'],
    questSummary: json['questSummary'],
  );
}

class HomeUser {
  final int userId;
  final String nickname;
  final String? profileImageUrl;

  HomeUser({required this.userId, required this.nickname, this.profileImageUrl});
  
  factory HomeUser.fromJson(Map<String, dynamic> json) => HomeUser(
    userId: json['userId'] ?? 0,
    nickname: json['nickname'] ?? '',
    profileImageUrl: json['profileImageUrl'],
  );
}

class HomeUserPlant {
  final int userPlantId;
  final int plantId;
  final String plantName;
  final String nickname;
  final String status;
  final String? imageUrl;
  final int? daysAfterPlanting;
  final int? remainingDays;

  HomeUserPlant({
    required this.userPlantId, required this.plantId, required this.plantName,
    required this.nickname, required this.status, this.imageUrl,
    this.daysAfterPlanting, this.remainingDays,
  });

  factory HomeUserPlant.fromJson(Map<String, dynamic> json) => HomeUserPlant(
    userPlantId: json['userPlantId'] ?? 0,
    plantId: json['plantId'] ?? 0,
    plantName: json['plantName'] ?? '',
    nickname: json['nickname'] ?? '',
    status: json['status'] ?? '',
    imageUrl: json['imageUrl'],
    daysAfterPlanting: json['daysAfterPlanting'],
    remainingDays: json['remainingDays'],
  );
}
