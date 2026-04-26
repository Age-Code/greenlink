import '../models/api_response.dart';
import '../models/attend.dart';
import 'api_client.dart';

class AttendService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<AttendModel>> getAttends({int? year, int? month}) async {
    try {
      String queryString = '';
      if (year != null && month != null) {
        queryString = '?year=$year&month=$month';
      }
      
      final response = await _client.get('/api/attends$queryString');
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '출석 현황 조회 성공',
        data: response['data'] != null ? AttendModel.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '출석 현황 조회 실패: $e');
    }
  }

  Future<ApiResponse<AttendResultModel>> checkTodayAttend() async {
    try {
      final response = await _client.post('/api/attends/today');
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '출석이 완료되었습니다.',
        data: response['data'] != null ? AttendResultModel.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '출석 실패: $e');
    }
  }
}
