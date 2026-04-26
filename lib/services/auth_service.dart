
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        body: {'email': email, 'password': password}
      );
      
      if (response['success'] == true && response['data'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', response['data']['accessToken']);
      }
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '로그인에 성공했습니다.',
        data: response['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: '로그인 실패: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signup(String email, String password, String nickname) async {
    try {
      final response = await _client.post(
        '/api/auth/signup',
        body: {'email': email, 'password': password, 'nickname': nickname}
      );
      
      return ApiResponse(
        success: response['success'] ?? true,
        message: response['message'] ?? '회원가입이 완료되었습니다.',
        data: response['data'],
      );
    } catch (e) {
      return ApiResponse(success: false, message: '회원가입 실패: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}

extension UserExt on User {
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'nickname': nickname,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
