class AttendModel {
  final int year;
  final int month;
  final int totalAttendCount;
  final int currentStreakCount;
  final List<AttendDayModel> attends;

  AttendModel({
    required this.year,
    required this.month,
    required this.totalAttendCount,
    required this.currentStreakCount,
    required this.attends,
  });

  factory AttendModel.fromJson(Map<String, dynamic> json) {
    return AttendModel(
      year: json['year'] as int,
      month: json['month'] as int,
      totalAttendCount: json['totalAttendCount'] as int? ?? 0,
      currentStreakCount: json['currentStreakCount'] as int? ?? 0,
      attends: (json['attends'] as List<dynamic>?)
              ?.map((e) => AttendDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AttendDayModel {
  final String attendDate;
  final int streakCount;

  AttendDayModel({
    required this.attendDate,
    required this.streakCount,
  });

  factory AttendDayModel.fromJson(Map<String, dynamic> json) {
    return AttendDayModel(
      attendDate: json['attendDate'] as String,
      streakCount: json['streakCount'] as int? ?? 0,
    );
  }
}

class AttendResultModel {
  final int attendId;
  final String attendDate;
  final int streakCount;

  AttendResultModel({
    required this.attendId,
    required this.attendDate,
    required this.streakCount,
  });

  factory AttendResultModel.fromJson(Map<String, dynamic> json) {
    return AttendResultModel(
      attendId: json['attendId'] as int,
      attendDate: json['attendDate'] as String,
      streakCount: json['streakCount'] as int? ?? 0,
    );
  }
}
