import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../models/user_plant_models.dart';

// ============================================================
// UserPlantService
// TEST 3: 내 식물 목록 조회
//   [x] GET /api/user-plants — Authorization 헤더 포함
//   [x] 식물 목록 표시, status 필터 동작
//   [x] 카드 클릭 → UserPlantDetailPage
//
// TEST 4: 식물 상세 조회
//   [x] GET /api/user-plants/{userPlantId}
//   [x] imageUrl, nickname, plantName, status, remainingDays 표시
//   [x] equippedPot null → 안내 표시
//   [x] equippedPot 있음 → 화분 카드 표시
//
// TEST 6: 씨앗 심기
//   [x] POST /api/user-plants — userItemId, nickname 전송
//   [x] 성공 → UserPlantDetailPage 이동
//
// TEST 7/8: 화분/영양제 연결 식물 조회
//   [x] getUserPlants(status: 'GROWING') 목록 확인
// ============================================================
class UserPlantService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<UserPlantSummary>>> getUserPlants({String? status}) async {
    debugPrint('[UserPlantService] 🌱 내 식물 목록 조회 (status=$status)');
    try {
      final path = '${ApiPaths.userPlants}${status != null ? '?status=$status' : ''}';
      final response = await _client.get(path);
      final result = ApiResponse<List<UserPlantSummary>>.fromJson(
        response,
        (data) => (data as List).map((i) => UserPlantSummary.fromJson(i)).toList(),
      );
      if (result.success) {
        debugPrint('[UserPlantService] ✅ 식물 ${result.data?.length ?? 0}개');
      }
      return result;
    } catch (e) {
      debugPrint('[UserPlantService] ❌ 목록 조회 예외: $e');
      return ApiResponse<List<UserPlantSummary>>(success: false, message: '내 식물 목록을 불러오지 못했습니다: $e');
    }
  }

  Future<ApiResponse<UserPlantDetail>> getUserPlantDetail(int userPlantId) async {
    debugPrint('[UserPlantService] 🔍 식물 상세 조회 (id=$userPlantId)');
    try {
      final response = await _client.get(ApiPaths.userPlantDetail(userPlantId));
      final result = ApiResponse<UserPlantDetail>.fromJson(
        response,
        (data) => UserPlantDetail.fromJson(data),
      );
      if (result.success && result.data != null) {
        debugPrint('[UserPlantService] ✅ nickname=${result.data!.nickname}, status=${result.data!.status}');
        debugPrint('[UserPlantService]   equippedPot=${result.data!.equippedPot?.name ?? "없음"}');
      }
      return result;
    } catch (e) {
      debugPrint('[UserPlantService] ❌ 상세 조회 예외: $e');
      return ApiResponse<UserPlantDetail>(success: false, message: '식물 정보를 불러오지 못했습니다: $e');
    }
  }

  Future<ApiResponse<UserPlantSummary>> plantSeed(int userItemId, String nickname) async {
    debugPrint('[UserPlantService] 🌱 씨앗 심기 (userItemId=$userItemId, nickname=$nickname)');
    try {
      final response = await _client.post(
        ApiPaths.userPlants,
        body: {'userItemId': userItemId, 'nickname': nickname},
      );
      final result = ApiResponse<UserPlantSummary>.fromJson(
        response,
        (data) => UserPlantSummary.fromJson(data),
      );
      if (result.success) {
        debugPrint('[UserPlantService] ✅ 씨앗 심기 성공 — userPlantId=${result.data?.userPlantId}');
      }
      return result;
    } catch (e) {
      debugPrint('[UserPlantService] ❌ 씨앗 심기 예외: $e');
      return ApiResponse<UserPlantSummary>(success: false, message: '씨앗 심기에 실패했습니다: $e');
    }
  }

  Future<ApiResponse<void>> updateUserPlantNickname(int userPlantId, String nickname) async {
    debugPrint('[UserPlantService] ✏️ 이름 수정 (id=$userPlantId, nickname=$nickname)');
    try {
      final response = await _client.patch(
        ApiPaths.userPlantDetail(userPlantId),
        body: {'nickname': nickname},
      );
      return ApiResponse<void>(
        success: response['success'] ?? true,
        message: response['message'] ?? '',
      );
    } catch (e) {
      debugPrint('[UserPlantService] ❌ 이름 수정 예외: $e');
      return ApiResponse<void>(success: false, message: '이름 수정에 실패했습니다: $e');
    }
  }

  Future<ApiResponse<void>> harvestUserPlant(int userPlantId) async {
    debugPrint('[UserPlantService] 🌾 수확 (id=$userPlantId)');
    try {
      final response = await _client.post(ApiPaths.harvestUserPlant(userPlantId));
      final success = response['success'] ?? true;
      debugPrint('[UserPlantService] ${success ? "✅ 수확 성공" : "❌ 수확 실패"}: ${response['message']}');
      return ApiResponse<void>(
        success: success,
        message: response['message'] ?? '',
      );
    } catch (e) {
      debugPrint('[UserPlantService] ❌ 수확 예외: $e');
      return ApiResponse<void>(success: false, message: '수확에 실패했습니다: $e');
    }
  }
}
