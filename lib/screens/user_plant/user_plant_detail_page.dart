import 'package:flutter/material.dart';
import '../../models/user_plant_models.dart';
import '../../models/iot_models.dart';
import '../../services/user_plant_service.dart';
import '../../services/iot_service.dart';
import '../../core/utils/plant_image_utils.dart';
import '../../core/widgets/greenlink_card.dart';
import '../iot/iot_status_page.dart';

class UserPlantDetailPage extends StatefulWidget {
  final int userPlantId;

  const UserPlantDetailPage({Key? key, required this.userPlantId}) : super(key: key);

  @override
  _UserPlantDetailPageState createState() => _UserPlantDetailPageState();
}

class _UserPlantDetailPageState extends State<UserPlantDetailPage> {
  final UserPlantService _plantService = UserPlantService();
  final IotService _iotService = IotService();

  UserPlantDetail? _plant;
  bool _isLoading = true;
  bool _isHarvesting = false;

  // IoT latest API에서 가져온 최신 이미지 정보
  PlantImageData? _latestImageData;
  String? _capturedAt;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final res = await _plantService.getUserPlantDetail(widget.userPlantId);
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _plant = res.data;
        _isLoading = false;
      });
      // IoT latest API에서 최신 이미지 버독 로드
      _loadLatestImage();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  /// IoT latest API로 최신 촬영 이미지 정보 로드 (비동기 - 화면 블로킹 없음)
  Future<void> _loadLatestImage() async {
    debugPrint('[UserPlantDetailPage] 📸 최신 이미지 로드 (plantId=${widget.userPlantId})');
    try {
      final res = await _iotService.getLatestStatus(widget.userPlantId);
      if (!mounted) return;
      final img = res.data?.latestImage;
      if (img != null) {
        setState(() {
          _latestImageData = img;
          _capturedAt = img.capturedAt;
        });
        debugPrint('[UserPlantDetailPage] ✅ imageUrl: ${img.imageUrl}, aiImageUrl: ${img.aiImageUrl}');
      }
    } catch (e) {
      debugPrint('[UserPlantDetailPage] ⚠️ 최신 이미지 로드 실패: $e');
    }
  }

  Future<void> _harvestPlant() async {
    if (_plant == null || _isHarvesting) return;

    setState(() => _isHarvesting = true);
    final res = await _plantService.harvestUserPlant(_plant!.userPlantId);
    if (!mounted) return;

    setState(() => _isHarvesting = false);

    if (res.success) {
      debugPrint('[UserPlantDetailPage] ✅ 수확 성공 → pop(true) 전달');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('식물 수확이 완료되었습니다.')));
      // E. 수확 성공 → 이전 화면(홈/식물목록)에 갱신 신호 전달
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  void _showEditNameBottomSheet() {
    if (_plant == null) return;
    
    final TextEditingController nameController = TextEditingController(text: _plant!.nickname);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 6,
                decoration: BoxDecoration(color: theme.disabledColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 24),
              Text("이름 수정하기", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "새로운 이름을 지어주세요",
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.2))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.2))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("취소"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isNotEmpty && newName != _plant!.nickname) {
                          Navigator.pop(context);
                          final res = await _plantService.updateUserPlantNickname(_plant!.userPlantId, newName);
                          if (res.success) {
                            if (mounted) _loadDetail();
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.primaryColorDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("저장"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  /// capturedAt 등 날짜+시간 표시용 (yyyy-MM-dd HH:mm)
  String _formatDateTimeStr(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dt = DateTime.parse(isoString);
      final pad = (int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${pad(dt.month)}-${pad(dt.day)} ${pad(dt.hour)}:${pad(dt.minute)}';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("식물 상세")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("식물 상세")),
        body: const Center(child: Text("데이터를 불러오지 못했습니다.")),
      );
    }

    String statusMsg = "";
    if (_plant!.status == 'GROWING') statusMsg = "나 조금씩 자라고 있어요";
    else if (_plant!.status == 'HARVESTABLE') statusMsg = "이제 수확할 수 있어요";
    else if (_plant!.status == 'HARVESTED') statusMsg = "도감에 기록됐어요";

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant!.nickname),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.colorScheme.secondary),
            onPressed: _showEditNameBottomSheet,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainCard(theme, statusMsg),
                  const SizedBox(height: 24),
                  Text("성장 정보", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildGrowthInfoCard(theme),
                  const SizedBox(height: 24),
                  Text("장착 화분", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPotCard(theme),
                  const SizedBox(height: 24),
                  // IoT 카드
                  _buildIotCard(theme),
                ],
              ),
            ),
          ),
          _buildBottomAction(theme),
        ],
      ),
    );
  }

  Widget _buildMainCard(ThemeData theme, String statusMsg) {
    // 상세 화면 정책: imageUrl → aiImageUrl → plant 기본 이미지
    final displayUrl = getDetailPlantImageUrl(
      aiImageUrl: _latestImageData?.aiImageUrl,
      originalImageUrl: _latestImageData?.imageUrl,
    ) ?? _plant!.imageUrl;

    return GreenlinkCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.disabledColor.withValues(alpha: 0.1)),
            ),
            child: Text(statusMsg, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
            child: ClipOval(
              child: displayUrl != null
                  ? Image.network(
                      displayUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.eco, size: 80, color: theme.primaryColor),
                    )
                  : Icon(Icons.eco, size: 80, color: theme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(_plant!.nickname, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(_plant!.plantName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
          // 최근 촬영 시간 표시
          if (_capturedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '최근 촬영: ${_formatDateTimeStr(_capturedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrowthInfoCard(ThemeData theme) {
    return GreenlinkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow("식물 종류", _plant!.plantName, theme),
          const SizedBox(height: 16),
          _buildInfoRow("함께한 지", "${_plant!.daysAfterPlanting ?? 0}일째", theme),
          const SizedBox(height: 16),
          _buildInfoRow("심은 날짜", _formatDate(_plant!.plantedAt), theme),
          if (_plant!.status == 'HARVESTED') ...[
            const SizedBox(height: 16),
            _buildInfoRow("수확 날짜", _formatDate(_plant!.harvestedAt), theme),
          ] else if (_plant!.remainingDays != null && _plant!.remainingDays! > 0) ...[
            const SizedBox(height: 16),
            _buildInfoRow("수확까지", "${_plant!.remainingDays}일 남음", theme),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPotCard(ThemeData theme) {
    if (_plant!.equippedPot == null) {
      return GreenlinkCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory_2_outlined, color: theme.disabledColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("아직 장착한 화분이 없어요", style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
                  const SizedBox(height: 2),
                  Text("인벤토리에서 화분을 장착해보세요", style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final pot = _plant!.equippedPot!;
    return GreenlinkCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: pot.imageUrl != null
                ? Image.network(pot.imageUrl!)
                : Icon(Icons.inventory_2, color: theme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("장착 중", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                ),
                const SizedBox(height: 6),
                Text(pot.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(ThemeData theme) {
    if (_plant!.status == 'HARVESTED') return const SizedBox();

    bool isHarvestable = _plant!.status == 'HARVESTABLE';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: isHarvestable && !_isHarvesting ? _harvestPlant : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isHarvestable ? theme.colorScheme.secondary : theme.disabledColor.withValues(alpha: 0.1),
          foregroundColor: isHarvestable ? Colors.white : theme.disabledColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isHarvesting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                isHarvestable ? "수확하기" : "아직 더 자라야 해요",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  /// IoT 섹션 카드 — IoT 상태 화면으로 이동하는 버튼
  Widget _buildIotCard(ThemeData theme) {
    return GreenlinkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sensors, color: theme.primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IoT 모니터링',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '온도·습도·조도·토양수분 및 물 주기·조명 제어',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.disabledColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IotStatusPage(
                      userPlantId: widget.userPlantId,
                      plantName: _plant?.nickname ?? '식물',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.monitor_heart_outlined, size: 18),
              label: const Text(
                'IoT 상태 보기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.primaryColorDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
