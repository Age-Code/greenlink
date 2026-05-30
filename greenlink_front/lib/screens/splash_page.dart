import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../theme/app_theme.dart';
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
    await Future.delayed(const Duration(milliseconds: 1200));
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
    return Scaffold(
      backgroundColor: AppColors.canvasSoft,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo mark — leaf symbol
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 48,
                color: AppColors.primaryStrong,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GreenLink',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '나만의 반려식물 성장 서비스',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.bodyMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
