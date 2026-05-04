import 'package:flutter/material.dart';
import '../../models/user_item_models.dart';
import '../../services/user_item_service.dart';
import '../../core/widgets/greenlink_card.dart';
import '../../core/widgets/greenlink_button.dart';
import '../user_plant/seed_planting_page.dart';

import 'inventory_action_sheets.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  InventoryPageState createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  final UserItemService _itemService = UserItemService();
  List<UserItemGroup>? _items;
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  /// 4. 인벤토리 갱신 — 외부에서 호출 가능한 refresh
  void refresh() {
    debugPrint('[InventoryPage] 🔄 refresh inventory');
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    String? itemType;
    if (_selectedFilter != 'ALL') {
      itemType = _selectedFilter;
    }

    final res = await _itemService.getUserItems(itemType: itemType);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _items = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _items = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  void _openEquipPotBottomSheet(int userItemId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: PotEquipBottomSheet(
          userItemId: userItemId,
          onSuccess: _loadItems,
        ),
      ),
    );
  }

  void _openUseNutrientBottomSheet(int userItemId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: NutrientUseBottomSheet(
          userItemId: userItemId,
          onSuccess: _loadItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text("인벤토리", style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text("식물 친구를 위한 작은 도구들이에요",
                style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),
          _buildFilterChips(theme),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items == null || _items!.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildItemList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final filters = [
      {'label': '전체', 'value': 'ALL'},
      {'label': '씨앗', 'value': 'SEED'},
      {'label': '화분', 'value': 'POT'},
      {'label': '영양제', 'value': 'NUTRIENT'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['value'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = f['value']!);
                  _loadItems();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: theme.colorScheme.secondary),
          const SizedBox(height: 24),
          Text("아직 가진 아이템이 없어요",
              style:
                  theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("출석과 퀘스트로 아이템을 모아보세요",
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildItemList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _items!.length,
      itemBuilder: (context, index) {
        final item = _items![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildItemCard(item, theme),
        );
      },
    );
  }

  Widget _buildItemCard(UserItemGroup item, ThemeData theme) {
    String badgeText = "";
    String hintText = "";
    String actionText = "";
    VoidCallback? onAction;
    String disabledText = "";

    int? firstOwnedUserItemId;
    try {
      firstOwnedUserItemId =
          item.items.firstWhere((i) => i.status == 'OWNED').userItemId;
    } catch (e) {
      // Ignore
    }

    switch (item.itemType) {
      case 'SEED':
        badgeText = "씨앗";
        hintText = "심을 수 있어요";
        actionText = "심기";
        disabledText = "사용 가능한 씨앗이 없어요";
        onAction = () async {
          // A. 씨앗 심기 성공 후 인벤토리 재조회
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SeedPlantingPage()),
          );
          if (!mounted) return;
          if (result == true) {
            debugPrint('[InventoryPage] 🔄 refresh inventory (after seed planting)');
            _loadItems();
          }
        };
        break;
      case 'POT':
        badgeText = "화분";
        hintText = "식물에게 장착할 수 있어요";
        actionText = "장착하기";
        disabledText = "장착 가능한 화분이 없어요";
        onAction = () {
          if (firstOwnedUserItemId != null) {
            _openEquipPotBottomSheet(firstOwnedUserItemId);
          }
        };
        break;
      case 'NUTRIENT':
        badgeText = "영양제";
        hintText = "식물에게 줄 수 있어요";
        actionText = "사용하기";
        disabledText = "사용 가능한 영양제가 없어요";
        onAction = () {
          if (firstOwnedUserItemId != null) {
            _openUseNutrientBottomSheet(firstOwnedUserItemId);
          }
        };
        break;
    }

    final bool canUse = item.usableCount > 0;

    return GreenlinkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.contain)
                    : Icon(Icons.eco, color: theme.primaryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(badgeText,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColorDark)),
                        ),
                        const SizedBox(width: 8),
                        Text(hintText, style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.name, style: theme.textTheme.titleMedium),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(item.description!,
                          style: theme.textTheme.bodyMedium),
                    ]
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCountColumn("보유", item.ownedCount, theme),
                _buildCountColumn("사용 가능", item.usableCount, theme,
                    isHighlight: true),
                _buildCountColumn("사용 완료", item.usedCount, theme),
              ],
            ),
          ),
          const SizedBox(height: 16),
          canUse
              ? GreenlinkButton(text: actionText, onPressed: onAction!)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(disabledText,
                        style: TextStyle(color: theme.disabledColor)),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCountColumn(String label, int count, ThemeData theme,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          "$count개",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isHighlight
                ? theme.primaryColorDark
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
