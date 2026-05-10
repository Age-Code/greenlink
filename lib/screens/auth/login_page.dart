import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/greenlink_button.dart';
import 'signup_page.dart';
import '../main_page.dart';

// ============================================================
// LoginPage — TEST 1: 로그인
// 체크리스트:
//   [x] POST /api/auth/login 호출
//   [x] success == true → accessToken 저장 → MainPage 이동
//   [x] success == false → message 스낵바 표시
//   [x] 네트워크 오류 시 앱이 죽지 않음
//   [x] 로딩 상태 표시
// ============================================================
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController(text: '');
  final _passwordCtrl = TextEditingController(text: '');
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _authService.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
    } else {
      setState(() => _errorMessage = res.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message), backgroundColor: Colors.red[700]),
      );
    }
  }

  void _loginWithKakao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final res = await _authService.loginWithKakao();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
    } else {
      setState(() => _errorMessage = res.message);
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final res = await _authService.loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
    } else {
      setState(() => _errorMessage = res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Icon(Icons.eco, size: 64, color: theme.primaryColor),
              const SizedBox(height: 16),
              Text('GreenLink', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('오늘도 식물 친구를 만나러 가볼까요?', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 48),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '이메일',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onSubmitted: (_) => _login(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 32),
              GreenlinkButton(
                text: '로그인',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _login,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage())),
                child: const Text('처음이에요, 회원가입하기'),
              ),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('또는 소셜 로그인', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialLoginButton(
                    onTap: _isLoading ? null : _loginWithKakao,
                    color: const Color(0xFFFEE500),
                    icon: Icons.chat_bubble,
                    iconColor: Colors.black,
                  ),
                  const SizedBox(width: 24),
                  _SocialLoginButton(
                    onTap: _isLoading ? null : _loginWithGoogle,
                    color: Colors.white,
                    icon: Icons.g_mobiledata,
                    iconSize: 40,
                    iconColor: Colors.red,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final BoxBorder? border;

  const _SocialLoginButton({
    this.onTap,
    required this.color,
    required this.icon,
    required this.iconColor,
    this.iconSize = 24,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
