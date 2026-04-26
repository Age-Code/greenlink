
import '../models/api_response.dart';
import '../models/item.dart';
import 'api_client.dart';

class ItemService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<InventoryItem>>> getUserItems({String? itemType, String? status}) async {
    try {
      final queryParams = <String>[];
      if (itemType != null) queryParams.add('itemType=$itemType');
      if (status != null) queryParams.add('status=$status');
      
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final path = '/api/user-items$queryString';
      final response = await _client.get(path);
      
      List<InventoryItem> items = [];
      if (response['data'] != null) {
        items = (response['data'] as List).map((i) => InventoryItem.fromJson(i)).toList();
      }
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '아이템 조회 성공',
        data: items,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '아이템 조회 실패: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> equipPot(int userItemId, int userPlantId) async {
    try {
      final response = await _client.post(
        '/api/user-items/$userItemId/equip-pot', 
        body: {'userPlantId': userPlantId}
      );
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '화분이 장착되었습니다.',
        data: response['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: '화분 장착 실패: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> useNutrient(int userItemId, int userPlantId) async {
    try {
      final response = await _client.post(
        '/api/user-items/$userItemId/use-nutrient', 
        body: {'userPlantId': userPlantId}
      );
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '영양제를 사용했습니다.',
        data: response['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: '영양제 사용 실패: $e');
    }
  }
}
