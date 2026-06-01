import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

// ============================================================
// ApiClient — 모든 HTTP 요청의 공통 처리
// 디버깅: 요청/응답 URL, method, status code, 인증 헤더 출력
// ============================================================
class ApiClient {
  static const String baseUrl = 'https://likepigs.shop/api';
  final TokenStorage _tokenStorage = TokenStorage();

  /// 401 발생 시 호출할 콜백 (SplashPage/Navigator 연결용)
  static Function()? onUnauthorized;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('[ApiClient] 🔑 Authorization 헤더 포함됨');
    } else {
      debugPrint('[ApiClient] ⚠️ Authorization 헤더 없음 — 토큰 미저장 상태');
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final url = '$baseUrl$path';
    debugPrint('[ApiClient] → GET $url');
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      return _processResponse('GET', url, response);
    } catch (e) {
      debugPrint('[ApiClient] ❌ GET $url 네트워크 오류: $e');
      return {'success': false, 'message': '네트워크 연결을 확인해주세요. ($e)'};
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final url = '$baseUrl$path';
    debugPrint('[ApiClient] → POST $url');
    if (body != null) debugPrint('[ApiClient]   body: ${jsonEncode(body)}');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse('POST', url, response);
    } catch (e) {
      debugPrint('[ApiClient] ❌ POST $url 네트워크 오류: $e');
      return {'success': false, 'message': '네트워크 연결을 확인해주세요. ($e)'};
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final url = '$baseUrl$path';
    debugPrint('[ApiClient] → PATCH $url');
    if (body != null) debugPrint('[ApiClient]   body: ${jsonEncode(body)}');
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse('PATCH', url, response);
    } catch (e) {
      debugPrint('[ApiClient] ❌ PATCH $url 네트워크 오류: $e');
      return {'success': false, 'message': '네트워크 연결을 확인해주세요. ($e)'};
    }
  }

  dynamic _processResponse(String method, String url, http.Response response) {
    debugPrint('[ApiClient] ← $method $url → ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('[ApiClient]   ✅ success=${decoded['success']} message=${decoded['message']}');
        return decoded;
      }
      return {'success': true, 'message': '요청 성공'};
    } else if (response.statusCode == 401) {
      debugPrint('[ApiClient]   🔒 401 Unauthorized — 로그인 필요, onUnauthorized 콜백 호출');
      onUnauthorized?.call();
      return {'success': false, 'message': '로그인이 필요합니다. 다시 로그인해주세요.'};
    } else {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          debugPrint('[ApiClient]   ❌ ${response.statusCode} message=${decoded['message']}');
          return decoded;
        } catch (_) {}
      }
      debugPrint('[ApiClient]   ❌ ${response.statusCode} — 서버 오류');
      return {'success': false, 'message': '서버 오류가 발생했습니다. (${response.statusCode})'};
    }
  }
}
