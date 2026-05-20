import 'package:flutter/material.dart';
import '../../models/automation_models.dart';
import '../../services/automation_service.dart';
import '../../theme/app_theme.dart';
import 'automation_setting_card.dart';
import 'automation_cards.dart';

// ============================================================
// AutomationSection
//   식물 상세 화면에 삽입되는 자동화 관리 섹션
//   상태관리: setState (기존 패턴 유지)
// ============================================================
class AutomationSection extends StatefulWidget {
  final int userPlantId;

  const AutomationSection({Key? key, required this.userPlantId}) : super(key: key);

  @override
  State<AutomationSection> createState() => _AutomationSectionState();
}

class _AutomationSectionState extends State<AutomationSection> {
  final AutomationService _service = AutomationService();

  // ── 상태 ────────────────────────────────────────────────
  bool _isLoadingSetting = false;
  bool _isSavingSetting = false;
  bool _isTraining = false;
  bool _isLoadingModel = false;
  bool _isLoadingLogs = false;

  AutomationSettingModel? _setting;
  AutomationModelModel? _model;
  List<AutomationLogModel> _logs = [];
  String? _errorMessage;

  // 로컬 토글 상태 (설정 저장 전 임시)
  bool _autoWaterEnabled = true;
  bool _autoLightEnabled = true;
  bool _autoOptimizeEnabled = true;
  String _decisionMode = 'HYBRID';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ── 전체 로드 ─────────────────────────────────────────────
  Future<void> _loadAll() async {
    await Future.wait([
      _loadSetting(),
      _loadModel(),
      _loadLogs(),
    ]);
  }

  // ── 자동화 설정 조회 ──────────────────────────────────────
  Future<void> _loadSetting() async {
    setState(() { _isLoadingSetting = true; _errorMessage = null; });
    final res = await _service.getAutomationSetting(widget.userPlantId);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _setting = res.data;
        _autoWaterEnabled = res.data!.autoWaterEnabled;
        _autoLightEnabled = res.data!.autoLightEnabled;
        _autoOptimizeEnabled = res.data!.autoOptimizeEnabled;
        _decisionMode = res.data!.decisionMode;
        _isLoadingSetting = false;
      });
    } else {
      setState(() {
        _errorMessage = '자동화 설정을 불러오지 못했습니다.';
        _isLoadingSetting = false;
      });
    }
  }

  // ── 학습 모델 조회 ────────────────────────────────────────
  Future<void> _loadModel() async {
    setState(() => _isLoadingModel = true);
    final model = await _service.getLatestAutomationModel(widget.userPlantId);
    if (!mounted) return;
    setState(() { _model = model; _isLoadingModel = false; });
  }

  // ── 자동화 로그 조회 ──────────────────────────────────────
  Future<void> _loadLogs() async {
    setState(() => _isLoadingLogs = true);
    final res = await _service.getAutomationLogs(widget.userPlantId);
    if (!mounted) return;
    setState(() {
      _logs = res.data ?? [];
      _isLoadingLogs = false;
    });
  }

  // ── 설정 저장 ─────────────────────────────────────────────
  Future<void> _saveSetting(AutomationSettingModel updated, String startTime, String endTime) async {
    setState(() => _isSavingSetting = true);
    final res = await _service.updateAutomationSetting(
      widget.userPlantId,
      updated,
      lightStartTimeRaw: startTime,
      lightEndTimeRaw: endTime,
    );
    if (!mounted) return;
    setState(() => _isSavingSetting = false);

    if (res.success) {
      _showSnack('자동화 설정이 저장되었습니다. ✅');
      await _loadSetting();
      await _loadLogs();
    } else {
      _showSnack('자동화 설정 저장에 실패했습니다. ❌');
    }
  }

  // ── 학습 실행 ─────────────────────────────────────────────
  Future<void> _trainModel() async {
    setState(() => _isTraining = true);
    final res = await _service.trainAutomationModel(widget.userPlantId);
    if (!mounted) return;
    setState(() => _isTraining = false);

    if (res.success) {
      _showSnack('학습이 완료되었습니다. 🤖');
      await Future.wait([_loadSetting(), _loadModel(), _loadLogs()]);
    } else {
      _showSnack('학습 실행에 실패했습니다. ❌');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── 현재 로컬 설정 반영한 모델 ────────────────────────────
  AutomationSettingModel _currentSetting() {
    final base = _setting ??
        AutomationSettingModel(
          userPlantId: widget.userPlantId,
          autoWaterEnabled: _autoWaterEnabled,
          autoLightEnabled: _autoLightEnabled,
          autoOptimizeEnabled: _autoOptimizeEnabled,
          decisionMode: _decisionMode,
        );
    return AutomationSettingModel(
      automationSettingId: base.automationSettingId,
      userPlantId: base.userPlantId,
      autoWaterEnabled: _autoWaterEnabled,
      autoLightEnabled: _autoLightEnabled,
      autoOptimizeEnabled: _autoOptimizeEnabled,
      decisionMode: _decisionMode,
      minLearningDataCount: base.minLearningDataCount,
      waterThresholdPercent: base.waterThresholdPercent,
      waterCooldownMinutes: base.waterCooldownMinutes,
      lightOnThresholdLux: base.lightOnThresholdLux,
      lightOffThresholdLux: base.lightOffThresholdLux,
      lightStartTime: base.lightStartTime,
      lightEndTime: base.lightEndTime,
      lightCooldownMinutes: base.lightCooldownMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 섹션 헤더 ──────────────────────────────────────
        const Text('자동화 관리',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.canvasGreenTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.hairline),
          ),
          child: const Text(
            '자동화 관리는 토양수분과 조도 데이터를 기반으로 물 주기와 조명을 자동으로 제어합니다. '
            '학습 기반 자동 최적화를 켜면 누적된 센서 데이터와 제어 기록을 분석해 식물별 기준값을 추천하거나 자동 반영할 수 있습니다.',
            style: TextStyle(fontSize: 12, color: AppColors.bodyMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),

        // ── 로딩 / 에러 ────────────────────────────────────
        if (_isLoadingSetting)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(color: AppColors.primaryStrong, strokeWidth: 2),
          ))
        else if (_errorMessage != null)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(_errorMessage!, style: const TextStyle(color: AppColors.dangerText, fontSize: 14)),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _loadAll,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ))
        else ...[
          // ── Card 1: 자동화 상태 ─────────────────────────
          AutomationStatusCard(
            setting: _currentSetting(),
            onWaterChanged: (v) => setState(() => _autoWaterEnabled = v),
            onLightChanged: (v) => setState(() => _autoLightEnabled = v),
            onOptimizeChanged: (v) => setState(() => _autoOptimizeEnabled = v),
            onDecisionModeChanged: (v) => setState(() => _decisionMode = v),
          ),
          const SizedBox(height: 16),

          // ── Card 2: 기준값 설정 ─────────────────────────
          AutomationThresholdCard(
            setting: _currentSetting(),
            isSaving: _isSavingSetting,
            onSave: _saveSetting,
          ),
          const SizedBox(height: 16),

          // ── Card 3: 학습 모델 ───────────────────────────
          AutomationModelCard(
            model: _model,
            isTraining: _isTraining,
            isLoadingModel: _isLoadingModel,
            onTrain: _trainModel,
            onRefresh: _loadModel,
          ),
          const SizedBox(height: 16),

          // ── Card 4: 자동화 로그 ─────────────────────────
          AutomationLogCard(logs: _logs, isLoading: _isLoadingLogs),
        ],
      ],
    );
  }
}
