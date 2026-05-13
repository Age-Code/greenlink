import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'home/home_page.dart';
import 'inventory/inventory_page.dart';
import 'collection/collection_page.dart';
import 'quest/quest_page.dart';
import '../widgets/debug_panel.dart';

// ============================================================
// MainPage — 하단 네비게이션 구조
// 탭 구성 (변경 금지):
//   0: 홈
//   1: 인벤토리
//   2: 도감
//   3: 퀘스트
//
// 탭 전환 시 해당 탭 GlobalKey를 통해 refresh() 호출
// ============================================================

/// 각 탭 페이지가 구현해야 할 refresh 인터페이스
abstract class RefreshablePage {
  void refresh();
}

final GlobalKey<HomePageState> homePageKey = GlobalKey<HomePageState>();
final GlobalKey<InventoryPageState> inventoryPageKey =
    GlobalKey<InventoryPageState>();
final GlobalKey<QuestPageState> questPageKey = GlobalKey<QuestPageState>();

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  late final List<Widget> _pages = [
    HomePage(key: homePageKey),
    InventoryPage(key: inventoryPageKey),
    CollectionPage(),
    QuestPage(key: questPageKey),
  ];

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    if (index == _currentIndex) {
      _refreshTab(index);
    } else {
      setState(() => _currentIndex = index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshTab(index);
      });
    }
  }

  void _refreshTab(int index) {
    switch (index) {
      case 0:
        homePageKey.currentState?.refresh();
        break;
      case 1:
        inventoryPageKey.currentState?.refresh();
        break;
      case 3:
        questPageKey.currentState?.refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // 🔧 DEV: Debug 버튼 (출시 전 제거)
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'debug_fab',
        onPressed: () => showDebugPanel(context),
        backgroundColor: AppColors.surfaceDark,
        tooltip: 'Debug Panel',
        child: const Icon(Icons.bug_report, color: AppColors.primaryOnDark, size: 18),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(top: BorderSide(color: AppColors.hairline, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                iconOutlined: Icons.home_outlined,
                label: '홈',
                selected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.backpack_rounded,
                iconOutlined: Icons.backpack_outlined,
                label: '인벤토리',
                selected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                iconOutlined: Icons.menu_book_outlined,
                label: '도감',
                selected: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _NavItem(
                icon: Icons.check_circle_rounded,
                iconOutlined: Icons.check_circle_outline_rounded,
                label: '퀘스트',
                selected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                selected ? icon : iconOutlined,
                size: 22,
                color: selected ? AppColors.primaryStrong : AppColors.bodyMuted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primaryStrong : AppColors.bodyMuted,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
