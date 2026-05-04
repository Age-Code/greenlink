import 'package:flutter/material.dart';
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
    if (index == _currentIndex) {
      // 같은 탭을 다시 눌렀을 때도 refresh
      _refreshTab(index);
    } else {
      setState(() => _currentIndex = index);
      // 새 탭 진입 시 refresh
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // 🔧 DEV: Debug 버튼 (출시 전 제거)
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'debug_fab',
        onPressed: () => showDebugPanel(context),
        backgroundColor: Colors.grey[800],
        tooltip: 'Debug Panel',
        child: const Icon(Icons.bug_report, color: Colors.greenAccent, size: 20),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.backpack), label: '인벤토리'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book), label: '도감'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle), label: '퀘스트'),
            ],
          ),
        ),
      ),
    );
  }
}
