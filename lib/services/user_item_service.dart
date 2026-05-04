import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../models/user_item_models.dart';

// ============================================================
// UserItemService
// TEST 5: 인벤토리 조회
//   [x] GET /api/user-items — Authorization 헤더 포함
//   [x] 씨앗/화분/영양제 필터 동작
//   [x] ownedCount, usableCount, usedCount 표시
//   [x] itemType별 버튼 표시
//
// TEST 6: 씨앗 목록 조회
//   [x] GET /api/user-items?itemType=SEED&status=OWNED
//   [x] 보유 씨앗 목록 표시
//
// TEST 7: 화분 장착
//   [x] POST /api/user-items/{userItemId}/equip-pot
//   [x] body: { userPlantId }
//   [x] 성공 메시지 표시, 인벤토리 재조회
//
// TEST 8: 영양제 사용
//   [x] POST /api/user-items/{userItemId}/use-nutrient
//   [x] body: { userPlantId }
//   [x] 성공 후 영양제 status USED 확인
// ============================================================
class UserItemService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<UserItemGroup>>> getUserItems({String? itemType, String? status}) async {
    debugPrint('[UserItemService] 🎒 인벤토리 조회 (itemType=$itemType, status=$status)');
    try {
      final queryParams = <String>[];
      if (itemType != null) queryParams.add('itemType=$itemType');
      if (status != null) queryParams.add('status=$status');
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final path = '${ApiPaths.userItems}$queryString';
      final response = await _client.get(path);
      final result = ApiResponse<List<UserItemGroup>>.fromJson(
        response,
        (data) => (data as List).map((i) => UserItemGroup.fromJson(i)).toList(),
      );
      if (result.success) {
        debugPrint('[UserItemService] ✅ 아이템 그룹 ${result.data?.length ?? 0}개');
      }
      return result;
    } catch (e) {
      debugPrint('[UserItemService] ❌ 인벤토리 조회 예외: $e');
      return ApiResponse<List<UserItemGroup>>(success: false, message: '인벤토리를 불러오지 못했습니다: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> equipPot(int userItemId, int userPlantId) async {
    debugPrint('[UserItemService] 🪴 화분 장착 (itemId=$userItemId, plantId=$userPlantId)');
    try {
      final response = await _client.post(
        ApiPaths.equipPot(userItemId),
        body: {'userPlantId': userPlantId},
      );
      debugPrint('[UserItemService] ${response['success'] == true ? "✅ 장착 성공" : "❌ 장착 실패"}: ${response['message']}');
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('[UserItemService] ❌ 화분 장착 예외: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: '화분 장착에 실패했습니다: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> useNutrient(int userItemId, int userPlantId) async {
    debugPrint('[UserItemService] 💧 영양제 사용 (itemId=$userItemId, plantId=$userPlantId)');
    try {
      final response = await _client.post(
        ApiPaths.useNutrient(userItemId),
        body: {'userPlantId': userPlantId},
      );
      debugPrint('[UserItemService] ${response['success'] == true ? "✅ 사용 성공" : "❌ 사용 실패"}: ${response['message']}');
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('[UserItemService] ❌ 영양제 사용 예외: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: '영양제 사용에 실패했습니다: $e');
    }
  }
}
