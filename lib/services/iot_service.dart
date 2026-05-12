import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../models/iot_models.dart';

// ============================================================
// IotService
//   - GET  /api/user-plants/{id}/iot/latest  → IotLatestStatus
//   - POST /api/user-plants/{id}/iot/water   → IotCommandResponse
//   - POST /api/user-plants/{id}/iot/light/on
//   - POST /api/user-plants/{id}/iot/light/off
// ============================================================
class IotService {
  final ApiClient _client = ApiClient();

  /// 최신 IoT 상태 조회
  Future<ApiResponse<IotLatestStatus>> getLatestStatus(int userPlantId) async {
    debugPrint('[IotService] 📡 최신 IoT 상태 조회 (plantId=$userPlantId)');
    try {
      final response = await _client.get(ApiPaths.iotLatest(userPlantId));
      final result = ApiResponse<IotLatestStatus>.fromJson(
        response,
        (data) => IotLatestStatus.fromJson(data),
      );
      if (result.success && result.data != null) {
        debugPrint('[IotService] ✅ IoT 상태 조회 성공');
      } else {
        debugPrint('[IotService] ⚠️ IoT 상태 조회 실패: ${result.message}');
      }
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ IoT 상태 조회 예외: $e');
      return ApiResponse<IotLatestStatus>(
          success: false, message: '서버에 연결할 수 없습니다. ($e)');
    }
  }

  /// 물 주기 요청
  Future<ApiResponse<IotCommandResponse>> requestWater(int userPlantId) async {
    debugPrint('[IotService] 💧 물 주기 요청 (plantId=$userPlantId)');
    try {
      final response = await _client.post(ApiPaths.iotWater(userPlantId));
      final result = ApiResponse<IotCommandResponse>.fromJson(
        response,
        (data) => IotCommandResponse.fromJson(data),
      );
      debugPrint('[IotService] ${result.success ? "✅" : "❌"} 물 주기: ${result.message}');
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ 물 주기 예외: $e');
      return ApiResponse<IotCommandResponse>(
          success: false, message: '서버에 연결할 수 없습니다. ($e)');
    }
  }

  /// LED 켜기
  Future<ApiResponse<Map<String, dynamic>>> lightOn(int userPlantId) async {
    debugPrint('[IotService] 💡 LED 켜기 (plantId=$userPlantId)');
    try {
      final response = await _client.post(ApiPaths.iotLightOn(userPlantId));
      final result = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => data is Map<String, dynamic> ? data : {},
      );
      debugPrint('[IotService] ${result.success ? "✅" : "❌"} LED 켜기: ${result.message}');
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ LED 켜기 예외: $e');
      return ApiResponse<Map<String, dynamic>>(
          success: false, message: '서버에 연결할 수 없습니다. ($e)');
    }
  }

  /// LED 끄기
  Future<ApiResponse<Map<String, dynamic>>> lightOff(int userPlantId) async {
    debugPrint('[IotService] 🌑 LED 끄기 (plantId=$userPlantId)');
    try {
      final response = await _client.post(ApiPaths.iotLightOff(userPlantId));
      final result = ApiResponse<Map<String, dynamic>>.fromJson(
        response,
        (data) => data is Map<String, dynamic> ? data : {},
      );
      debugPrint('[IotService] ${result.success ? "✅" : "❌"} LED 끄기: ${result.message}');
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ LED 끄기 예외: $e');
      return ApiResponse<Map<String, dynamic>>(
          success: false, message: '서버에 연결할 수 없습니다. ($e)');
    }
  }

  /// 최신 이미지 URL만 반환 — 홈/상세 화면 이미지 로드용
  /// latestImage가 null이거나 imageUrl이 없으면 null 반환
  Future<String?> getLatestImageUrl(int userPlantId) async {
    try {
      final res = await getLatestStatus(userPlantId);
      final img = res.data?.latestImage;
      final url = img?.imageUrl;
      return (url != null && url.isNotEmpty) ? url : null;
    } catch (_) {
      return null;
    }
  }
}
