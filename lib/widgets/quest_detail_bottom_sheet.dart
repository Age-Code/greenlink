import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';
import '../screens/main_page.dart';

class QuestDetailBottomSheet extends StatefulWidget {
  final int userQuestId;
  final VoidCallback onRewardReceived;

  const QuestDetailBottomSheet({
    Key? key,
    required this.userQuestId,
    required this.onRewardReceived,
  }) : super(key: key);

  @override
  _QuestDetailBottomSheetState createState() => _QuestDetailBottomSheetState();
}

class _QuestDetailBottomSheetState extends State<QuestDetailBottomSheet> {
  final QuestService _questService = QuestService();
  UserQuestDetail? _detail;
  bool _isLoading = true;
  bool _isReceiving = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final res = await _questService.getUserQuestDetail(widget.userQuestId);
    if (!mounted) return;
    
    if (res.success && res.data != null) {
      setState(() {
        _detail = res.data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  Future<void> _receiveReward() async {
    if (_isReceiving || _detail == null) return;
    
    setState(() => _isReceiving = true);
    final res = await _questService.receiveReward(_detail!.userQuestId);
    if (!mounted) return;

    setState(() => _isReceiving = false);

    if (res.success && res.data != null) {
      widget.onRewardReceived();
      Navigator.pop(context); // Close bottom sheet first
      _showRewardSuccessDialog(res.data!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  void _showRewardSuccessDialog(QuestRewardResponse rewardData) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.redeem, size: 60, color: theme.colorScheme.secondary),
                const SizedBox(height: 16),
                Text("보상을 받았어요", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("작은 약속을 지켜서 선물을 받았어요", style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.disabledColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.disabledColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: rewardData.reward.itemName.contains('영양제') 
                            ? Icon(Icons.water_drop, color: theme.colorScheme.secondary)
                            : Icon(Icons.eco, color: theme.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "${rewardData.reward.itemName} ${rewardData.reward.quantity}개가 인벤토리에 들어왔어요",
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
                        child: const Text("확인"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 인벤토리로 이동 (메인페이지에서 인벤토리 탭으로 교체)
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.primaryColorDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("인벤토리 보러가기"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'DAILY': return '오늘의 약속';
      case 'WEEKLY': return '이번 주 약속';
      case 'MONTHLY': return '이번 달 약속';
      case 'ACHIEVEMENT': return '도전 기록';
      default: return type;
    }
  }

  String _getTargetTypeName(String type) {
    switch (type) {
      case 'ATTEND': return '출석';
      case 'WATERING': return '물주기';
      case 'GROW_PLANT': return '식물 키우기';
      case 'HARVEST': return '수확';
      default: return type;
    }
  }

  Widget _buildTypeBadge(String type, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getTypeName(type),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.disabledColor),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color badgeColor;
    Color textColor;
    String text;

    switch (status) {
      case 'IN_PROGRESS':
        badgeColor = theme.primaryColor.withOpacity(0.2);
        textColor = theme.primaryColorDark;
        text = '진행 중';
        break;
      case 'ACHIEVABLE':
        badgeColor = theme.colorScheme.secondary.withOpacity(0.2);
        textColor = theme.colorScheme.secondary;
        text = '보상 가능';
        break;
      case 'COMPLETED':
        badgeColor = theme.disabledColor.withOpacity(0.1);
        textColor = theme.disabledColor;
        text = '완료';
        break;
      case 'EXPIRED':
        badgeColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = '기간 만료';
        break;
      default:
        badgeColor = theme.disabledColor.withOpacity(0.1);
        textColor = theme.disabledColor;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_detail == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text("데이터를 불러오지 못했습니다."),
      );
    }

    double progressRate = _detail!.targetValue == 0 ? 0 : _detail!.progressValue / _detail!.targetValue;
    if (progressRate > 1.0) progressRate = 1.0;

    final isAchievable = _detail!.status == 'ACHIEVABLE';
    final isCompleted = _detail!.status == 'COMPLETED';
    final isExpired = _detail!.status == 'EXPIRED';

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: theme.disabledColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTypeBadge(_detail!.questType, theme),
              _buildStatusBadge(_detail!.status, theme),
            ],
          ),
          const SizedBox(height: 16),
          Text(_detail!.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (_detail!.description != null) ...[
            const SizedBox(height: 8),
            Text(_detail!.description!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("목표: ${_getTargetTypeName(_detail!.targetType)}", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text("${_detail!.progressValue} / ${_detail!.targetValue}", style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressRate,
              backgroundColor: theme.disabledColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(isAchievable ? theme.colorScheme.secondary : theme.primaryColor),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_detail!.startedAt != null)
                Expanded(child: Text("시작일: ${_formatDate(_detail!.startedAt)}", style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor))),
              if (_detail!.expiredAt != null)
                Expanded(child: Text("마감일: ${_formatDate(_detail!.expiredAt)}", style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor), textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 32),
          
          // Reward area
          if (_detail!.rewardItem != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _detail!.rewardItem!.imageUrl != null
                        ? Image.network(_detail!.rewardItem!.imageUrl!)
                        : Icon(Icons.star, color: theme.colorScheme.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("보상", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("${_detail!.rewardItem!.name} ${_detail!.rewardQuantity}개", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.disabledColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text("등록된 보상이 없어요", style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor), textAlign: TextAlign.center),
            ),
          ],

          const SizedBox(height: 32),

          if (isAchievable)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReceiving ? null : _receiveReward,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isReceiving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("보상 받기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          else if (isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.disabledColor.withOpacity(0.1),
                  foregroundColor: theme.disabledColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("받았어요", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          else if (isExpired)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.disabledColor.withOpacity(0.1),
                  foregroundColor: theme.disabledColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("이번 약속은 시간이 지났어요", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.disabledColor.withOpacity(0.1),
                  foregroundColor: theme.disabledColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("아직 진행 중이에요", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
