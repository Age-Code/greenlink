import 'package:flutter/material.dart';
import '../../models/user_item_models.dart';
import '../../services/user_item_service.dart';
import '../../services/user_plant_service.dart';
import '../../core/widgets/greenlink_card.dart';

class SeedPlantingPage extends StatefulWidget {
  @override
  _SeedPlantingPageState createState() => _SeedPlantingPageState();
}

class _SeedPlantingPageState extends State<SeedPlantingPage> {
  final UserItemService _itemService = UserItemService();
  final UserPlantService _plantService = UserPlantService();
  
  List<UserItemGroup>? _seeds;
  bool _isLoading = true;
  bool _isPlanting = false;
  
  int? _selectedUserItemId;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSeeds();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadSeeds() async {
    setState(() => _isLoading = true);
    final res = await _itemService.getUserItems(itemType: 'SEED', status: 'OWNED');
    if (!mounted) return;
    
    if (res.success && res.data != null) {
      setState(() {
        _seeds = res.data!.where((s) => s.usableCount > 0 && s.items.isNotEmpty).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _seeds = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  Future<void> _plantSeed() async {
    if (_selectedUserItemId == null) return;
    
    setState(() => _isPlanting = true);
    
    final nickname = _nicknameController.text.trim();
    final res = await _plantService.plantSeed(_selectedUserItemId!, nickname);
    
    if (!mounted) return;
    setState(() => _isPlanting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('식물이 생성되었습니다.')));
      Navigator.pop(context, true); // true indicates a refresh is needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("씨앗 심기"),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _seeds == null || _seeds!.isEmpty
              ? _buildEmptyState(theme)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        "새로운 식물 친구를 만나볼까요?",
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("보유 중인 씨앗", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ..._seeds!.map((seed) => _buildSeedCard(seed, theme)).toList(),
                            const SizedBox(height: 32),
                            Text("이름 지어주기", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nicknameController,
                              decoration: InputDecoration(
                                hintText: "식물 친구 이름을 지어주세요",
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: theme.disabledColor.withValues(alpha: 0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: theme.primaryColor),
                                ),
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
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: (_selectedUserItemId == null || _isPlanting) ? null : _plantSeed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.primaryColorDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isPlanting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("심기 완료", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSeedCard(UserItemGroup seed, ThemeData theme) {
    // Select the first OWNED userItemId for this seed
    final ownedItems = seed.items.where((i) => i.status == 'OWNED').toList();
    if (ownedItems.isEmpty) return const SizedBox();

    final userItemId = ownedItems.first.userItemId;
    final isSelected = _selectedUserItemId == userItemId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserItemId = userItemId;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: GreenlinkCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: seed.imageUrl != null
                    ? Image.network(seed.imageUrl!)
                    : Icon(Icons.eco, size: 32, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seed.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (seed.description != null) ...[
                      const SizedBox(height: 4),
                      Text(seed.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "보유 ${seed.usableCount}개",
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColorDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass, size: 80, color: theme.disabledColor.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text("지금 심을 수 있는 씨앗이 없어요", style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor)),
          const SizedBox(height: 8),
          Text("퀘스트 보상으로 씨앗을 얻어보세요", style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: theme.scaffoldBackgroundColor,
              foregroundColor: theme.textTheme.bodyLarge?.color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.disabledColor.withValues(alpha: 0.2)),
              ),
            ),
            child: const Text("돌아가기"),
          ),
        ],
      ),
    );
  }
}
