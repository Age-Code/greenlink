import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'auth/login_page.dart';

/// 계정 설정 및 로그아웃 페이지
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.dangerText, size: 28),
              ),
              const SizedBox(height: 20),
              const Text(
                '로그아웃',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                '정말 로그아웃 하시겠어요?',
                style: TextStyle(fontSize: 15, color: AppColors.bodyMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerBg,
                        foregroundColor: AppColors.dangerText,
                        side: const BorderSide(color: AppColors.dangerBorder),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    debugPrint('[SettingsPage] 🚪 로그아웃 실행');
    await AuthService().logout();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('계정'),
        backgroundColor: AppColors.canvas,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          // 섹션 레이블
          const Text(
            '계정 관리',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),

          // 로그아웃 항목
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.hairline),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.dangerText, size: 22),
              ),
              title: const Text(
                '로그아웃',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.dangerText, fontSize: 16),
              ),
              subtitle: const Text(
                '계정에서 로그아웃합니다',
                style: TextStyle(color: AppColors.bodyMuted, fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.dangerText, size: 20),
              onTap: () => _logout(context),
            ),
          ),
          const SizedBox(height: 32),

          // 앱 정보
          const Text(
            '앱 정보',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.hairline),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Icon(Icons.eco_rounded, color: AppColors.primaryStrong, size: 22),
              title: Text(
                'GreenLink',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 16),
              ),
              subtitle: Text(
                '나만의 반려식물 성장 서비스',
                style: TextStyle(color: AppColors.bodyMuted, fontSize: 14),
              ),
              trailing: Text(
                'v1.0.0',
                style: TextStyle(color: AppColors.bodySoft, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
