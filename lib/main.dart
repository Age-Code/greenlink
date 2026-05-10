import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'theme/app_theme.dart';
import 'screens/splash_page.dart';

void main() {
  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '20675888d2a1900e54cd1d88d75e4688');
  runApp(const GreenLinkApp());
}

class GreenLinkApp extends StatelessWidget {
  const GreenLinkApp({Key? key}) : super(key: key);

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
