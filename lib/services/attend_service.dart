import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../models/attend_models.dart';

// ============================================================
// AttendService
// GET /api/attends?year={year}&month={month}
//   응답 data: { year, month, totalAttendCount, currentStreakCount,
//               attends: [{ attendDate: "yyyy-MM-dd", streakCount }] }
//
// POST /api/attends/today
//   성공 후 GET /api/attends 재조회 필요
// ============================================================
class AttendService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<AttendMonth>> getAttends(
      {required int year, required int month}) async {
    debugPrint('[AttendService] 📅 출석 기록 조회 ($year년 $month월)');
    try {
      final path = '${ApiPaths.attends}?year=$year&month=$month';
      final response = await _client.get(path);
      final result = ApiResponse<AttendMonth>.fromJson(
        response,
        (data) => AttendMonth.fromJson(data),
      );
      if (result.success && result.data != null) {
        final d = result.data!;
        debugPrint(
          '[AttendService] ✅ totalAttendCount=${d.totalAttendCount},'
          ' currentStreakCount=${d.currentStreakCount},'
          ' attends=${d.attends.length}개',
        );
      } else {
        debugPrint('[AttendService] ⚠️ 출석 조회 실패: ${result.message}');
      }
      return result;
    } catch (e) {
      debugPrint('[AttendService] ❌ 출석 기록 조회 예외: $e');
      return ApiResponse<AttendMonth>(
          success: false, message: '출석 기록을 불러오지 못했습니다: $e');
    }
  }

  Future<ApiResponse<AttendTodayResponse>> attendToday() async {
    debugPrint('[AttendService] ✋ 오늘 출석 체크');
    try {
      final response = await _client.post(ApiPaths.attendToday);
      final result = ApiResponse<AttendTodayResponse>.fromJson(
        response,
        (data) => AttendTodayResponse.fromJson(data),
      );
      if (result.success && result.data != null) {
        debugPrint(
            '[AttendService] ✅ 출석 성공 — streak=${result.data!.streakDays}일 연속');
      } else {
        debugPrint('[AttendService] ℹ️ 출석 결과: ${result.message}');
      }
      return result;
    } catch (e) {
      debugPrint('[AttendService] ❌ 출석 예외: $e');
      return ApiResponse<AttendTodayResponse>(
          success: false, message: '출석 체크에 실패했습니다: $e');
    }
  }
}
