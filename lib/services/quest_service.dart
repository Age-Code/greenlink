import '../models/api_response.dart';
import '../models/quest.dart';
import 'api_client.dart';

class QuestService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<UserQuest>>> getUserQuests({String? status, String? questType}) async {
    try {
      final queryParams = <String>[];
      if (status != null && status != 'ALL') queryParams.add('status=$status');
      if (questType != null && questType != 'ALL') queryParams.add('questType=$questType');

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _client.get('/api/user-quests$queryString');
      
      List<UserQuest> quests = [];
      if (response['data'] != null) {
        quests = (response['data'] as List).map((i) => UserQuest.fromJson(i)).toList();
      }
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '내 퀘스트 목록 조회 성공',
        data: quests,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '퀘스트 조회 실패: $e');
    }
  }

  Future<ApiResponse<UserQuestDetail>> getUserQuestDetail(int userQuestId) async {
    try {
      final response = await _client.get('/api/user-quests/$userQuestId');
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '내 퀘스트 상세 조회 성공',
        data: response['data'] != null ? UserQuestDetail.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '상세 조회 실패: $e');
    }
  }

  Future<ApiResponse<QuestRewardResponse>> receiveReward(int userQuestId) async {
    try {
      final response = await _client.post('/api/user-quests/$userQuestId/reward');
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '퀘스트 보상을 수령했습니다.',
        data: response['data'] != null ? QuestRewardResponse.fromJson(response['data']) : null,
      );
    } catch (e) {
      return ApiResponse(success: false, message: '보상 수령 실패: $e');
    }
  }
}
