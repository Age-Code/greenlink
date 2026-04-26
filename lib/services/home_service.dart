
import '../models/api_response.dart';
import '../models/plant.dart';
import 'api_client.dart';

class HomeService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<Map<String, dynamic>>> getHomeData() async {
    try {
      final response = await _client.get('/api/home');
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '홈 데이터 조회 성공',
        data: response['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: '홈 데이터 조회 실패: $e');
    }
  }
}
