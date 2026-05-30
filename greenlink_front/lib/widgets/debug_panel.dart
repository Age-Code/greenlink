import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/network/token_storage.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_page.dart';

// ============================================================
// DebugPanel — 개발용 디버그 패널
// 사용법: 화면 우하단 FAB 또는 AppBar action에서 열기
// 확인 가능 항목:
//   - 저장된 accessToken 앞 40자
//   - 로그아웃 버튼
//   - API Base URL 확인
// ============================================================
class DebugPanel extends StatefulWidget {
  const DebugPanel({Key? key}) : super(key: key);

  @override
  _DebugPanelState createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  final _tokenStorage = TokenStorage();
  final _authService = AuthService();
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await _tokenStorage.getAccessToken();
    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  Future<void> _logout(BuildContext ctx) async {
    await _authService.logout();
    if (!ctx.mounted) return;
    Navigator.pushAndRemoveUntil(
      ctx,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Text('🔧 Debug Panel',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.grey, height: 24),

            // Base URL
            _DebugRow(label: 'Base URL', value: 'http://localhost:8080/api'),
            const SizedBox(height: 12),

            // Token
            Text('Access Token', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 6),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.greenAccent)
            else if (_token == null || _token!.isEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('❌ 토큰 없음 — 로그인 필요',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              )
            else
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _token!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('토큰이 클립보드에 복사되었습니다')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ ${_token!.substring(0, _token!.length.clamp(0, 40))}...',
                        style: const TextStyle(
                            color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text('(탭하면 전체 토큰 복사)',
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Refresh + Logout
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loadToken,
                    icon: const Icon(Icons.refresh, size: 16, color: Colors.greenAccent),
                    label: const Text('새로고침', style: TextStyle(color: Colors.greenAccent)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.greenAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('로그아웃'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;

  const _DebugRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// 어디서든 DebugPanel을 띄우는 헬퍼
void showDebugPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const DebugPanel(),
  );
}
