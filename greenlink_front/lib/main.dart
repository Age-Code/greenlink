// 앱 진입점 — Kakao SDK 초기화, 테마 적용

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'theme/app_theme.dart';
import 'screens/splash_page.dart';

// 앱 실행 — Kakao SDK 초기화 후 runApp 호출
void main() {
  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '20675888d2a1900e54cd1d88d75e4688');
  runApp(const GreenLinkApp());
}

// GreenLinkApp — 앱 진입점 — Kakao SDK 초기화, 테마 적용
class GreenLinkApp extends StatelessWidget {
  const GreenLinkApp({Key? key}) : super(key: key);

  // 위젯 렌더링
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenLink',
      theme: AppTheme.lightTheme,
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
