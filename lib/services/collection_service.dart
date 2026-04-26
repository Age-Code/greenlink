import '../models/api_response.dart';
import '../models/collection.dart';
import 'api_client.dart';

class CollectionService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<CollectionItem>>> getCollections() async {
    try {
      final response = await _client.get('/api/collections');
      
      List<CollectionItem> collections = [];
      if (response['data'] != null) {
        collections = (response['data'] as List).map((i) => CollectionItem.fromJson(i)).toList();
      }
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '도감 조회 성공',
        data: collections,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '도감 조회 실패: $e');
    }
  }

  Future<ApiResponse<CollectionDetail>> getCollectionDetail(int plantId) async {
    try {
      final response = await _client.get('/api/collections/$plantId');
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '도감 상세 조회 성공',
        data: response['data'] != null ? CollectionDetail.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '도감 상세 조회 실패: $e');
    }
  }
}
