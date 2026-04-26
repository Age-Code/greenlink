
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'collection_page.dart';
import 'quest_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    InventoryPage(),
    CollectionPage(),
    QuestPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "홈"),
              BottomNavigationBarItem(icon: Icon(Icons.backpack), label: "인벤토리"),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "도감"),
              BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "퀘스트"),
            ],
          ),
        ),
      ),
    );
  }
}

