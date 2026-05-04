import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import 'auth/login_page.dart';
import 'main_page.dart';

// ============================================================
// SplashPage
// - 앱 시작 시 토큰 유무 확인
// - 토큰 있으면 → MainPage
// - 토큰 없으면 → LoginPage
// - ApiClient.onUnauthorized 콜백 등록 (401 시 자동 로그아웃)
// ============================================================
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 401 발생 시 로그인 화면으로 이동
    ApiClient.onUnauthorized = () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    };
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (!mounted) return;

    if (token != null && token.isNotEmpty && token != 'mock_token') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 80, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text('GreenLink', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('나만의 작은 반려식물 돌봄', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
