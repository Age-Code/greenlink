
import '../models/api_response.dart';
import '../models/plant.dart';
import 'api_client.dart';

class PlantService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<UserPlant>>> getUserPlants({String? status}) async {
    try {
      final path = '/api/user-plants${status != null ? '?status=$status' : ''}';
      final response = await _client.get(path);
      
      List<UserPlant> plants = [];
      if (response['data'] != null) {
        plants = (response['data'] as List).map((p) => UserPlant.fromJson(p)).toList();
      }
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '내 식물 목록 조회 성공',
        data: plants,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '내 식물 목록 조회 실패: $e');
    }
  }

  Future<ApiResponse<void>> updateUserPlantNickname(int userPlantId, String nickname) async {
    try {
      final response = await _client.patch(
        '/api/user-plants/$userPlantId',
        body: {'nickname': nickname},
      );
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '식물 이름이 수정되었습니다.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: '이름 수정 실패: $e');
    }
  }

  Future<ApiResponse<void>> harvestUserPlant(int userPlantId) async {
    try {
      final response = await _client.post('/api/user-plants/$userPlantId/harvest');
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '식물 수확이 완료되었습니다.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: '수확 실패: $e');
    }
  }

  Future<ApiResponse<UserPlant>> getUserPlantDetail(int userPlantId) async {
    try {
      final response = await _client.get('/api/user-plants/$userPlantId');
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '내 식물 상세 조회 성공',
        data: response['data'] != null ? UserPlant.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '내 식물 상세 조회 실패: $e');
    }
  }

  Future<ApiResponse<UserPlant>> plantSeed(int userItemId, String nickname) async {
    try {
      final response = await _client.post(
        '/api/user-plants',
        body: {
          'userItemId': userItemId,
          'nickname': nickname,
        }
      );
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '식물이 생성되었습니다.',
        data: response['data'] != null ? UserPlant.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '씨앗 심기 실패: $e');
    }
  }
}
