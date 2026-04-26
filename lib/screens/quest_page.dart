import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/quest_detail_bottom_sheet.dart';
import 'attend_page.dart';
import 'main_page.dart';

class QuestPage extends StatefulWidget {
  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  final QuestService _questService = QuestService();
  
  List<UserQuest>? _allQuests;
  List<UserQuest>? _filteredQuests;
  bool _isLoading = true;

  String _selectedStatus = 'ALL';
  String _selectedQuestType = 'ALL';

  final Map<String, String> _statusFilters = {
    'ALL': '전체',
    'IN_PROGRESS': '진행 중',
    'ACHIEVABLE': '보상 가능',
    'COMPLETED': '완료',
    'EXPIRED': '만료',
  };

  final Map<String, String> _typeFilters = {
    'ALL': '전체 유형',
    'DAILY': '일일',
    'WEEKLY': '주간',
    'MONTHLY': '월간',
    'ACHIEVEMENT': '업적',
  };

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);
    final res = await _questService.getUserQuests();
    if (res.success && res.data != null) {
      if (!mounted) return;
      setState(() {
        _allQuests = res.data;
        _applyFilters();
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _allQuests = [];
        _filteredQuests = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  void _applyFilters() {
    if (_allQuests == null) return;
    _filteredQuests = _allQuests!.where((q) {
      bool passStatus = _selectedStatus == 'ALL' || q.status == _selectedStatus;
      bool passType = _selectedQuestType == 'ALL' || q.questType == _selectedQuestType;
      return passStatus && passType;
    }).toList();
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedQuestType = type;
      _applyFilters();
    });
  }

  Future<void> _receiveReward(UserQuest quest) async {
    final res = await _questService.receiveReward(quest.userQuestId);
    if (!mounted) return;

    if (res.success && res.data != null) {
      _showRewardSuccessDialog(res.data!);
      _loadQuests(); // 갱신
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
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage())); // 인벤토리로 이동
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

  void _showDetailBottomSheet(UserQuest quest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return QuestDetailBottomSheet(
          userQuestId: quest.userQuestId,
          onRewardReceived: _loadQuests,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("퀘스트"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: theme.colorScheme.secondary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AttendPage()));
            },
            tooltip: '출석',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "식물 친구와 함께하는 작은 약속이에요",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 12),
          if (!_isLoading && _allQuests != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildSummaryCard(theme),
            ),
          const SizedBox(height: 16),
          _buildFilters(theme),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQuests == null || _filteredQuests!.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _filteredQuests!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildQuestCard(_filteredQuests![index], theme);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    int total = _allQuests!.length;
    int inProgress = _allQuests!.where((q) => q.status == 'IN_PROGRESS').length;
    int achievable = _allQuests!.where((q) => q.status == 'ACHIEVABLE').length;
    int completed = _allQuests!.where((q) => q.status == 'COMPLETED').length;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("진행 중", inProgress, theme),
          Container(width: 1, height: 40, color: theme.disabledColor.withOpacity(0.2)),
          _buildSummaryItem("받을 보상", achievable, theme, highlight: achievable > 0),
          Container(width: 1, height: 40, color: theme.disabledColor.withOpacity(0.2)),
          _buildSummaryItem("완료", completed, theme),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, ThemeData theme, {bool highlight = false}) {
    return Column(
      children: [
        Text(
          "$count개",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? theme.colorScheme.secondary : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _statusFilters.entries.map((e) {
              final isSelected = _selectedStatus == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(e.value),
                  selected: isSelected,
                  onSelected: (_) => _onStatusChanged(e.key),
                  backgroundColor: theme.scaffoldBackgroundColor,
                  selectedColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? theme.primaryColorDark : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? theme.primaryColor : theme.disabledColor.withOpacity(0.2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _typeFilters.entries.map((e) {
              final isSelected = _selectedQuestType == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(e.value, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) => _onTypeChanged(e.key),
                  backgroundColor: theme.scaffoldBackgroundColor,
                  selectedColor: theme.disabledColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard(UserQuest quest, ThemeData theme) {
    final bool isExpired = quest.status == 'EXPIRED';
    final bool isAchievable = quest.status == 'ACHIEVABLE';
    final bool isCompleted = quest.status == 'COMPLETED';
    
    double progressRate = quest.targetValue == 0 ? 0 : quest.progressValue / quest.targetValue;
    if (progressRate > 1.0) progressRate = 1.0;

    String cardMessage = "조금만 더 해볼까요?";
    if (isAchievable) cardMessage = "받을 수 있는 보상이 있어요";
    if (isCompleted) cardMessage = "이미 보상을 받았어요";
    if (isExpired) cardMessage = "이번 약속은 지나갔어요";

    return GestureDetector(
      onTap: () => _showDetailBottomSheet(quest),
      child: Opacity(
        opacity: isExpired ? 0.6 : 1.0,
        child: CustomCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTypeBadge(quest.questType, theme),
                  _buildStatusBadge(quest.status, theme),
                ],
              ),
              const SizedBox(height: 16),
              Text(quest.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(cardMessage, style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressRate,
                        backgroundColor: theme.disabledColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAchievable ? theme.colorScheme.secondary : theme.primaryColor,
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "${quest.progressValue} / ${quest.targetValue}",
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (isAchievable) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _receiveReward(quest),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("보상 받기", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              if (isCompleted) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.disabledColor.withOpacity(0.1),
                      foregroundColor: theme.disabledColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("받았어요"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    String msg1 = "아직 진행 중인 퀘스트가 없어요";
    String msg2 = "식물을 돌보면 새로운 약속이 생길 거예요";

    if (_selectedStatus == 'ACHIEVABLE') {
      msg1 = "지금 받을 수 있는 보상은 없어요";
      msg2 = "조금만 더 돌보면 보상이 기다리고 있어요";
    } else if (_selectedStatus == 'COMPLETED') {
      msg1 = "아직 완료한 약속이 없어요";
      msg2 = "";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: theme.disabledColor.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            msg1,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
          ),
          if (msg2.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              msg2,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
            ),
          ]
        ],
      ),
    );
  }
}
