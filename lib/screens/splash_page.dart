
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    // 만약 토큰이 이전에 사용하던 가짜 토큰이거나 문제가 있다면 제거
    if (token == 'mock_token') {
      await prefs.remove('accessToken');
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    if (token != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text("GreenLink", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("나만의 작은 반려식물 돌봄", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
