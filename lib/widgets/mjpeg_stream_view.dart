import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================
// MjpegStreamView
//   - http 패키지로 MJPEG 스트림을 직접 읽어 Image.memory로 렌더링
//   - 외부 MJPEG 패키지 불필요
//   - 새로고침: key를 교체하면 dispose 후 재생성됨
// ============================================================
class MjpegStreamView extends StatefulWidget {
  final String streamUrl;
  final double height;
  final BoxFit fit;

  const MjpegStreamView({
    Key? key,
    required this.streamUrl,
    this.height = 240,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<MjpegStreamView> createState() => _MjpegStreamViewState();
}

class _MjpegStreamViewState extends State<MjpegStreamView> {
  Uint8List? _frameBytes;   // 현재 렌더링할 JPEG 프레임
  bool _isConnecting = true;
  String? _error;

  http.Client? _client;
  StreamSubscription<List<int>>? _subscription;

  // 프레임 파싱용 버퍼
  final List<int> _buffer = [];

  // JPEG SOI(Start Of Image) / EOI(End Of Image) 마커
  static const int _soiByte0 = 0xFF;
  static const int _soiByte1 = 0xD8;
  static const int _eoiByte0 = 0xFF;
  static const int _eoiByte1 = 0xD9;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }

  void _stopStream() {
    _subscription?.cancel();
    _client?.close();
    _subscription = null;
    _client = null;
  }

  Future<void> _startStream() async {
    setState(() {
      _isConnecting = true;
      _error = null;
      _frameBytes = null;
    });
    _buffer.clear();

    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.streamUrl));
      // MJPEG 스트림은 Authorization 불필요 (Cloudflare 공개 스트림)
      final response = await _client!.send(request).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('카메라 연결 시간 초과'),
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      if (!mounted) return;
      setState(() => _isConnecting = false);

      _subscription = response.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _error = '실시간 카메라를 불러올 수 없습니다.';
      });
      debugPrint('[MjpegStreamView] ❌ 연결 실패: $e');
    }
  }

  void _onData(List<int> chunk) {
    _buffer.addAll(chunk);
    _extractFrames();
  }

  void _onError(Object e) {
    debugPrint('[MjpegStreamView] ❌ 스트림 오류: $e');
    if (!mounted) return;
    setState(() => _error = '실시간 카메라 연결이 끊겼습니다.');
  }

  void _onDone() {
    debugPrint('[MjpegStreamView] 🔌 스트림 종료');
    if (!mounted) return;
    if (_frameBytes == null) {
      setState(() => _error = '실시간 카메라를 불러올 수 없습니다.');
    }
  }

  /// 버퍼에서 JPEG SOI~EOI 구간을 찾아 프레임 추출
  void _extractFrames() {
    while (_buffer.length >= 2) {
      // SOI 마커(FF D8) 탐색
      final start = _findSequence(_buffer, _soiByte0, _soiByte1, 0);
      if (start == -1) {
        // SOI 없음 — 불필요한 데이터 제거 (마지막 1바이트는 남김)
        if (_buffer.length > 1) {
          _buffer.removeRange(0, _buffer.length - 1);
        }
        break;
      }

      // SOI 이전 데이터 제거
      if (start > 0) _buffer.removeRange(0, start);

      // EOI 마커(FF D9) 탐색 (SOI 다음부터)
      final end = _findSequence(_buffer, _eoiByte0, _eoiByte1, 2);
      if (end == -1) break; // 아직 프레임 끝 미도달

      // JPEG 프레임 추출 (SOI ~ EOI 포함)
      final frameEnd = end + 2;
      final frame = Uint8List.fromList(_buffer.sublist(0, frameEnd));
      _buffer.removeRange(0, frameEnd);

      // 렌더링
      if (mounted) {
        setState(() => _frameBytes = frame);
      }
    }
  }

  /// bytes 내에서 [b0, b1] 시퀀스의 첫 위치를 반환, 없으면 -1
  int _findSequence(List<int> bytes, int b0, int b1, int from) {
    for (int i = from; i < bytes.length - 1; i++) {
      if (bytes[i] == b0 && bytes[i + 1] == b1) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isConnecting) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.primaryColor),
              const SizedBox(height: 12),
              Text(
                '카메라 연결 중…',
                style: TextStyle(color: theme.disabledColor, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: widget.height,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_frameBytes == null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Image.memory(
        _frameBytes!,
        fit: widget.fit,
        gaplessPlayback: true, // 프레임 전환 시 깜빡임 방지
      ),
    );
  }
}
