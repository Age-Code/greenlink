import 'package:flutter/material.dart';
import '../../models/iot_models.dart';
import '../../services/iot_service.dart';
import '../../core/config/camera_config.dart';
import '../../widgets/mjpeg_stream_view.dart';

// ============================================================
// IotStatusPage
//   - 실시간 카메라: MjpegStreamView (http 직접 파싱)
//   - 센서 데이터: 온도/습도/조도/토양수분
//   - 물 주기 / LED 켜기·끄기 제어
//   - IoT API 실패와 카메라 실패는 완전히 분리
// ============================================================
class IotStatusPage extends StatefulWidget {
  final int userPlantId;
  final String plantName;

  const IotStatusPage({
    Key? key,
    required this.userPlantId,
    required this.plantName,
  }) : super(key: key);

  @override
  State<IotStatusPage> createState() => _IotStatusPageState();
}

class _IotStatusPageState extends State<IotStatusPage> {
  final IotService _iotService = IotService();

  IotLatestStatus? _status;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isWatering = false;
  bool _isLightingOn = false;
  bool _isLightingOff = false;

  // 카메라 위젯을 다시 생성하기 위한 키
  int _cameraReloadKey = 0;

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final res = await _iotService.getLatestStatus(widget.userPlantId);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _status = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res.message;
      });
    }
  }

  Future<void> _onWater() async {
    setState(() => _isWatering = true);
    final res = await _iotService.requestWater(widget.userPlantId);
    if (!mounted) return;
    setState(() => _isWatering = false);
    _showSnack(
      res.success
          ? (res.message.isNotEmpty ? res.message : '물 주기 요청이 전송되었습니다.')
          : res.message,
      success: res.success,
    );
    if (res.success) await _loadLatest();
  }

  Future<void> _onLightOn() async {
    setState(() => _isLightingOn = true);
    final res = await _iotService.lightOn(widget.userPlantId);
    if (!mounted) return;
    setState(() => _isLightingOn = false);
    _showSnack(
      res.success
          ? (res.message.isNotEmpty ? res.message : '조명을 켰습니다.')
          : res.message,
      success: res.success,
    );
    if (res.success) await _loadLatest();
  }

  Future<void> _onLightOff() async {
    setState(() => _isLightingOff = true);
    final res = await _iotService.lightOff(widget.userPlantId);
    if (!mounted) return;
    setState(() => _isLightingOff = false);
    _showSnack(
      res.success
          ? (res.message.isNotEmpty ? res.message : '조명을 껐습니다.')
          : res.message,
      success: res.success,
    );
    if (res.success) await _loadLatest();
  }

  void _showSnack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green[700] : Colors.red[700],
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      final p = (int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${p(dt.month)}-${p(dt.day)} ${p(dt.hour)}:${p(dt.minute)}';
    } catch (_) {
      return raw;
    }
  }

  bool get _anyBusy => _isWatering || _isLightingOn || _isLightingOff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plantName} IoT'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '센서 새로고침',
            onPressed: _isLoading ? null : _loadLatest,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError(theme)
              : _buildContent(theme),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 72, color: theme.disabledColor),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodyLarge?.copyWith(color: theme.disabledColor),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadLatest,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final status = _status!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 재배 공간
          if (status.growSpace != null)
            _SectionCard(
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status.growSpace!.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // 실시간 카메라 카드 (IoT API와 독립)
          _buildLiveCameraCard(theme),
          const SizedBox(height: 16),

          // 환경 데이터
          _buildEnvironmentCard(theme, status.environment),
          const SizedBox(height: 16),

          // 토양수분
          _buildSoilCard(theme, status.soil),
          const SizedBox(height: 28),

          // 제어 버튼
          _buildControlButtons(theme),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── 실시간 카메라 카드 ─────────────────────────────────────

  Widget _buildLiveCameraCard(ThemeData theme) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.videocam_outlined,
                      size: 18, color: theme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    '실시간 카메라',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColorDark,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _cameraReloadKey++),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 16, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '새로고침',
                        style:
                            TextStyle(fontSize: 12, color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '현재 재배 공간의 실시간 화면입니다.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.disabledColor),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MjpegStreamView(
              key: ValueKey(_cameraReloadKey),
              streamUrl: CameraConfig.streamUrl,
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ── 환경 카드 ─────────────────────────────────────────────

  Widget _buildEnvironmentCard(ThemeData theme, EnvironmentData? env) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.thermostat_outlined, label: '환경 데이터', theme: theme),
          const SizedBox(height: 16),
          if (env == null)
            _NoDataRow()
          else ...[
            Row(
              children: [
                Expanded(
                  child: _EnvItem(
                    icon: Icons.thermostat,
                    iconColor: Colors.orange,
                    label: '온도',
                    value: '${env.temperature.toStringAsFixed(1)} °C',
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _EnvItem(
                    icon: Icons.water_drop_outlined,
                    iconColor: Colors.blue,
                    label: '습도',
                    value: '${env.humidity.toStringAsFixed(1)} %',
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EnvItem(
                    icon: Icons.wb_sunny_outlined,
                    iconColor: Colors.amber,
                    label: '조도',
                    value: '${env.light.toStringAsFixed(0)} lux',
                    theme: theme,
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            if (env.measuredAt != null) ...[
              const SizedBox(height: 12),
              Text(
                '최근 측정: ${_formatDateTime(env.measuredAt)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.disabledColor),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── 토양수분 카드 ──────────────────────────────────────────

  Widget _buildSoilCard(ThemeData theme, SoilData? soil) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.grass_outlined, label: '토양 수분', theme: theme),
          const SizedBox(height: 16),
          if (soil == null)
            _NoDataRow()
          else ...[
            Row(
              children: [
                Expanded(
                  child: _EnvItem(
                    icon: Icons.water,
                    iconColor: Colors.teal,
                    label: '토양수분',
                    value: '${soil.soilMoisturePercent.toStringAsFixed(1)} %',
                    theme: theme,
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (soil.soilMoisturePercent / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: theme.disabledColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  soil.soilMoisturePercent < 30
                      ? Colors.red
                      : soil.soilMoisturePercent < 60
                          ? Colors.orange
                          : Colors.teal,
                ),
              ),
            ),
            if (soil.measuredAt != null) ...[
              const SizedBox(height: 8),
              Text(
                '최근 측정: ${_formatDateTime(soil.measuredAt)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.disabledColor),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── 제어 버튼 ─────────────────────────────────────────────

  Widget _buildControlButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ControlButton(
          label: '물 주기',
          icon: Icons.water_drop,
          color: Colors.blue,
          isLoading: _isWatering,
          isDisabled: _anyBusy,
          onPressed: _onWater,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ControlButton(
                label: '조명 켜기',
                icon: Icons.light_mode,
                color: Colors.amber[700]!,
                isLoading: _isLightingOn,
                isDisabled: _anyBusy,
                onPressed: _onLightOn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ControlButton(
                label: '조명 끄기',
                icon: Icons.nightlight_round,
                color: Colors.indigo,
                isLoading: _isLightingOff,
                isDisabled: _anyBusy,
                onPressed: _onLightOff,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: (_isLoading || _anyBusy) ? null : _loadLatest,
          icon: const Icon(Icons.refresh),
          label: const Text('센서 데이터 새로고침'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  const _SectionTitle(
      {required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColorDark,
          ),
        ),
      ],
    );
  }
}

class _NoDataRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '아직 측정 데이터가 없습니다.',
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }
}

class _EnvItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final ThemeData theme;

  const _EnvItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.disabledColor)),
            Text(value,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            )
          : Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }
}
