import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("계정")),
      body: Center(child: Text("계정 설정 및 정보 표시")),
    );
  }
}
