import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../models/home_models.dart';

// ============================================================
// HomeService
// TEST 2: 홈 조회
//   [x] GET /api/home — Authorization 헤더 포함 확인
//   [x] user.nickname 정상 표시
//   [x] mainUserPlant null → 빈 상태 표시
//   [x] mainUserPlant 있음 → 식물 카드 표시
// ============================================================
class HomeService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<HomeResponse>> getHomeData() async {
    debugPrint('[HomeService] 🏠 홈 데이터 조회');
    try {
      final response = await _client.get(ApiPaths.home);
      final result = ApiResponse<HomeResponse>.fromJson(
        response,
        (data) => HomeResponse.fromJson(data),
      );
      if (result.success && result.data != null) {
        debugPrint('[HomeService] ✅ nickname=${result.data!.user.nickname}');
        debugPrint('[HomeService]   mainUserPlant=${result.data!.mainUserPlant?.nickname ?? "null"}');
      }
      return result;
    } catch (e) {
      debugPrint('[HomeService] ❌ 홈 조회 예외: $e');
      return ApiResponse<HomeResponse>(success: false, message: '홈 데이터를 불러오지 못했습니다: $e');
    }
  }
}
