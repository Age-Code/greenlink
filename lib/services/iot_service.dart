import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../models/iot_models.dart';

// ============================================================
// IotService
//   - GET  /api/user-plants/{id}/iot/latest  → IotLatestStatus
//   - POST /api/user-plants/{id}/iot/refresh → SensorRefreshResponse
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
        success: false,
        message: '서버에 연결할 수 없습니다. ($e)',
      );
    }
  }

  /// 라즈베리파이 환경 센서 새로고침 요청
  /// 온도·습도·조도만 즉시 측정 대상이며 토양수분은 ESP32 주기 업로드를 따른다.
  Future<ApiResponse<SensorRefreshResponse>> requestSensorRefresh(
    int userPlantId,
  ) async {
    debugPrint('[IotService] 🔄 센서 새로고침 요청 (plantId=$userPlantId)');
    try {
      final response = await _client.post(ApiPaths.iotRefresh(userPlantId));
      final result = ApiResponse<SensorRefreshResponse>.fromJson(
        response,
        (data) => SensorRefreshResponse.fromJson(data),
      );
      debugPrint(
        '[IotService] ${result.success ? "✅" : "❌"} 센서 새로고침: ${result.message}',
      );
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ 센서 새로고침 예외: $e');
      return ApiResponse<SensorRefreshResponse>(
        success: false,
        message: '센서 새로고침 중 오류가 발생했습니다. ($e)',
      );
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
      debugPrint(
        '[IotService] ${result.success ? "✅" : "❌"} 물 주기: ${result.message}',
      );
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ 물 주기 예외: $e');
      return ApiResponse<IotCommandResponse>(
        success: false,
        message: '서버에 연결할 수 없습니다. ($e)',
      );
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
      debugPrint(
        '[IotService] ${result.success ? "✅" : "❌"} LED 켜기: ${result.message}',
      );
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ LED 켜기 예외: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: '서버에 연결할 수 없습니다. ($e)',
      );
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
      debugPrint(
        '[IotService] ${result.success ? "✅" : "❌"} LED 끄기: ${result.message}',
      );
      return result;
    } catch (e) {
      debugPrint('[IotService] ❌ LED 끄기 예외: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: '서버에 연결할 수 없습니다. ($e)',
      );
    }
  }

  /// 최신 이미지 정보(PlantImageData) 반환 — 홈/상세 화면 이미지 로드용
  /// latestImage가 null이면 null 반환
  Future<PlantImageData?> getLatestImageData(int userPlantId) async {
    try {
      final res = await getLatestStatus(userPlantId);
      return res.data?.latestImage;
    } catch (_) {
      return null;
    }
  }
}
