/// 출석 월간 응답
/// GET /api/attends 응답 data 구조:
/// {
///   "year": 2026,
///   "month": 4,
///   "totalAttendCount": 12,
///   "currentStreakCount": 5,
///   "attends": [{ "attendDate": "2026-04-20", "streakCount": 1 }, ...]
/// }
class AttendMonth {
  final int year;
  final int month;
  final int totalAttendCount;
  final int currentStreakCount;
  final List<AttendDay> attends;

  AttendMonth({
    required this.year,
    required this.month,
    required this.totalAttendCount,
    required this.currentStreakCount,
    required this.attends,
  });

  factory AttendMonth.fromJson(Map<String, dynamic> json) => AttendMonth(
        year: json['year'] ?? 0,
        month: json['month'] ?? 0,
        totalAttendCount: json['totalAttendCount'] ?? 0,
        currentStreakCount: json['currentStreakCount'] ?? 0,
        attends: (json['attends'] as List?)
                ?.map((e) => AttendDay.fromJson(e))
                .toList() ??
            [],
      );
}

/// 개별 출석 기록
/// attendDate: "2026-04-20" 형식
class AttendDay {
  final String attendDate; // "yyyy-MM-dd"
  final int streakCount;

  AttendDay({required this.attendDate, required this.streakCount});

  factory AttendDay.fromJson(Map<String, dynamic> json) => AttendDay(
        attendDate: json['attendDate'] ?? '',
        streakCount: json['streakCount'] ?? 0,
      );
}

/// POST /api/attends/today 응답
class AttendTodayResponse {
  final bool isConsecutive;
  final int streakDays;

  AttendTodayResponse({required this.isConsecutive, required this.streakDays});

  factory AttendTodayResponse.fromJson(Map<String, dynamic> json) =>
      AttendTodayResponse(
        isConsecutive: json['isConsecutive'] ?? false,
        streakDays: json['streakDays'] ?? 1,
      );
}
