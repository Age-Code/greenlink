
import 'package:flutter/material.dart';
import '../models/attend.dart';
import '../services/attend_service.dart';
import '../widgets/custom_card.dart';

class AttendPage extends StatefulWidget {
  @override
  _AttendPageState createState() => _AttendPageState();
}

class _AttendPageState extends State<AttendPage> {
  final AttendService _attendService = AttendService();
  
  AttendModel? _attendData;
  bool _isLoading = true;
  
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadAttends();
  }

  Future<void> _loadAttends() async {
    setState(() => _isLoading = true);
    final res = await _attendService.getAttends(year: _currentYear, month: _currentMonth);
    if (res.success && res.data != null) {
      if (!mounted) return;
      setState(() {
        _attendData = res.data;
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _attendData = null;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  void _changeMonth(int delta) {
    int newMonth = _currentMonth + delta;
    int newYear = _currentYear;
    
    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    } else if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }
    
    setState(() {
      _currentYear = newYear;
      _currentMonth = newMonth;
    });
    _loadAttends();
  }

  Future<void> _doTodayAttend() async {
    final res = await _attendService.checkTodayAttend();
    if (!mounted) return;

    if (res.success && res.data != null) {
      _showSuccessDialog(res.data!.streakCount);
      
      final now = DateTime.now();
      if (_currentYear == now.year && _currentMonth == now.month) {
        _loadAttends(); // Refresh if on current month
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.message),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showSuccessDialog(int streakCount) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, size: 64, color: theme.primaryColor),
                const SizedBox(height: 24),
                Text("오늘도 만났어요!", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "$streakCount일째 이어지는 만남이에요",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.primaryColorDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("출석"),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "오늘도 식물 친구를 만나러 왔어요",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthSelector(theme),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSummaryCards(theme),
                        const SizedBox(height: 24),
                        _buildCalendarCard(theme),
                        if (_attendData != null && _attendData!.attends.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Column(
                              children: [
                                Text("이번 달에는 아직 만난 날이 없어요", style: TextStyle(color: theme.disabledColor)),
                                const SizedBox(height: 4),
                                Text("오늘 첫 만남을 기록해볼까요?", style: TextStyle(color: theme.disabledColor)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _doTodayAttend,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: const Text("오늘 식물 친구 만나기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => _changeMonth(-1),
        ),
        const SizedBox(width: 16),
        Text(
          "$_currentYear년 $_currentMonth월",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.chevron_right, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    final int total = _attendData?.totalAttendCount ?? 0;
    final int streak = _attendData?.currentStreakCount ?? 0;

    return Row(
      children: [
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.eco, color: theme.primaryColor, size: 28),
                const SizedBox(height: 8),
                Text("이번 달", style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text("$total번 만났어요", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.local_fire_department, color: theme.colorScheme.secondary, size: 28),
                const SizedBox(height: 8),
                Text("연속 만남", style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text("$streak일째", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(ThemeData theme) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel(text: "월"),
              _WeekdayLabel(text: "화"),
              _WeekdayLabel(text: "수"),
              _WeekdayLabel(text: "목"),
              _WeekdayLabel(text: "금"),
              _WeekdayLabel(text: "토"),
              _WeekdayLabel(text: "일"),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(theme),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1(Mon) ~ 7(Sun)
    
    int totalCells = startingWeekday - 1 + daysInMonth;
    int rows = (totalCells / 7).ceil();

    final attendedDates = <String>{};
    if (_attendData != null) {
      for (var a in _attendData!.attends) {
        attendedDates.add(a.attendDate);
      }
    }

    final now = DateTime.now();

    List<Widget> gridRows = [];
    int currentDay = 1;

    for (int i = 0; i < rows; i++) {
      List<Widget> rowChildren = [];
      for (int j = 1; j <= 7; j++) {
        if (i == 0 && j < startingWeekday) {
          rowChildren.add(const Expanded(child: SizedBox()));
        } else if (currentDay <= daysInMonth) {
          String dateStr = "$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${currentDay.toString().padLeft(2, '0')}";
          bool isAttended = attendedDates.contains(dateStr);
          bool isToday = _currentYear == now.year && _currentMonth == now.month && currentDay == now.day;
          bool isFuture = DateTime(_currentYear, _currentMonth, currentDay).isAfter(DateTime(now.year, now.month, now.day));

          rowChildren.add(
            Expanded(
              child: _DayCell(
                day: currentDay,
                isAttended: isAttended,
                isToday: isToday,
                isFuture: isFuture,
                theme: theme,
              ),
            ),
          );
          currentDay++;
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }
      gridRows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: rowChildren));
      if (i < rows - 1) gridRows.add(const SizedBox(height: 16));
    }

    return Column(children: gridRows);
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).disabledColor,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isAttended;
  final bool isToday;
  final bool isFuture;
  final ThemeData theme;

  const _DayCell({
    required this.day,
    required this.isAttended,
    required this.isToday,
    required this.isFuture,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    if (isFuture) textColor = theme.disabledColor.withOpacity(0.4);
    if (isAttended) textColor = theme.primaryColorDark;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAttended ? theme.primaryColor : Colors.transparent,
            border: isToday && !isAttended ? Border.all(color: theme.colorScheme.secondary, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: isToday || isAttended ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (isAttended)
          Icon(Icons.eco, size: 12, color: theme.primaryColorDark)
        else
          const SizedBox(height: 12),
      ],
    );
  }
}
