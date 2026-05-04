import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_paths.dart';
import '../core/network/token_storage.dart';
import '../models/auth_models.dart';

// ============================================================
// AuthService
// TEST 1: 로그인
//   - POST /api/auth/login
//   - success == true 확인
//   - data.accessToken 존재 확인
//   - TokenStorage에 저장 확인
//   - 로그인 성공 후 MainPage로 이동 확인
// ============================================================
class AuthService {
  final ApiClient _client = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<ApiResponse<LoginResponse>> login(String email, String password) async {
    debugPrint('[AuthService] 🔐 로그인 시도 — email: $email');
    try {
      final response = await _client.post(
        ApiPaths.login,
        body: {'email': email, 'password': password},
      );

      if (response['success'] == true && response['data'] != null) {
        final loginData = LoginResponse.fromJson(response['data']);
        await _tokenStorage.saveAccessToken(loginData.accessToken);
        debugPrint('[AuthService] ✅ 로그인 성공 — token 저장 완료');
        debugPrint('[AuthService]   nickname: ${loginData.user.nickname}');
        return ApiResponse<LoginResponse>(
          success: true,
          message: response['message'] ?? '로그인 성공',
          data: loginData,
        );
      } else {
        debugPrint('[AuthService] ❌ 로그인 실패 — ${response['message']}');
        return ApiResponse<LoginResponse>(
          success: false,
          message: response['message'] ?? '로그인에 실패했습니다.',
        );
      }
    } catch (e) {
      debugPrint('[AuthService] ❌ 로그인 예외: $e');
      return ApiResponse<LoginResponse>(success: false, message: '로그인 중 오류가 발생했습니다: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signup(
      String email, String password, String nickname) async {
    debugPrint('[AuthService] 📝 회원가입 시도 — email: $email, nickname: $nickname');
    try {
      final response = await _client.post(
        ApiPaths.signup,
        body: {'email': email, 'password': password, 'nickname': nickname},
      );
      return ApiResponse<Map<String, dynamic>>(
        success: response['success'] ?? false,
        message: response['message'] ?? '회원가입이 완료되었습니다.',
        data: response['data'],
      );
    } catch (e) {
      debugPrint('[AuthService] ❌ 회원가입 예외: $e');
      return ApiResponse<Map<String, dynamic>>(success: false, message: '회원가입 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> logout() async {
    debugPrint('[AuthService] 🚪 로그아웃 — token 삭제');
    await _tokenStorage.clearAccessToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getAccessToken();
    final loggedIn = token != null && token.isNotEmpty;
    debugPrint('[AuthService] 🔍 로그인 상태 확인: $loggedIn');
    return loggedIn;
  }
}
