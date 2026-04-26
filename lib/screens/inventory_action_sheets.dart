
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/item_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/selectable_user_plant_card.dart';
import 'seed_planting_page.dart';

class PotEquipBottomSheet extends StatefulWidget {
  final int userItemId;
  final VoidCallback onSuccess;

  const PotEquipBottomSheet({Key? key, required this.userItemId, required this.onSuccess}) : super(key: key);

  @override
  _PotEquipBottomSheetState createState() => _PotEquipBottomSheetState();
}

class _PotEquipBottomSheetState extends State<PotEquipBottomSheet> {
  final PlantService _plantService = PlantService();
  final ItemService _itemService = ItemService();
  
  List<UserPlant>? _plants;
  bool _isLoading = true;
  int? _selectedPlantId;
  bool _isEquipping = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  void _loadPlants() async {
    final res = await _plantService.getUserPlants(status: 'GROWING');
    if (!mounted) return;
    setState(() {
      _plants = res.data ?? [];
      _isLoading = false;
    });
  }

  void _equip() async {
    if (_selectedPlantId == null) return;
    setState(() => _isEquipping = true);
    final res = await _itemService.equipPot(widget.userItemId, _selectedPlantId!);
    if (!mounted) return;
    setState(() => _isEquipping = false);

    if (res.success) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text("어떤 식물에게 장착할까요?", style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text("화분을 선물할 식물 친구를 골라주세요", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plants!.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        itemCount: _plants!.length,
                        itemBuilder: (context, index) {
                          final plant = _plants![index];
                          return SelectableUserPlantCard(
                            plant: plant,
                            isSelected: _selectedPlantId == plant.userPlantId,
                            onTap: () {
                              setState(() => _selectedPlantId = plant.userPlantId);
                            },
                          );
                        },
                      ),
            ),
            if (_plants != null && _plants!.isNotEmpty) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: "장착하기",
                isDisabled: _selectedPlantId == null,
                isLoading: _isEquipping,
                onPressed: _equip,
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.nature_people_outlined, size: 60, color: theme.disabledColor),
        const SizedBox(height: 16),
        Text("아직 돌볼 식물이 없어요", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("씨앗을 심고 첫 식물 친구를 만나보세요", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        CustomButton(
          text: "씨앗 심기",
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SeedPlantingPage()));
          },
        )
      ],
    );
  }
}

class NutrientUseBottomSheet extends StatefulWidget {
  final int userItemId;
  final VoidCallback onSuccess;

  const NutrientUseBottomSheet({Key? key, required this.userItemId, required this.onSuccess}) : super(key: key);

  @override
  _NutrientUseBottomSheetState createState() => _NutrientUseBottomSheetState();
}

class _NutrientUseBottomSheetState extends State<NutrientUseBottomSheet> {
  final PlantService _plantService = PlantService();
  final ItemService _itemService = ItemService();
  
  List<UserPlant>? _plants;
  bool _isLoading = true;
  int? _selectedPlantId;
  bool _isUsing = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  void _loadPlants() async {
    final res = await _plantService.getUserPlants(status: 'GROWING');
    if (!mounted) return;
    setState(() {
      _plants = res.data ?? [];
      _isLoading = false;
    });
  }

  void _useNutrient() async {
    if (_selectedPlantId == null) return;
    setState(() => _isUsing = true);
    final res = await _itemService.useNutrient(widget.userItemId, _selectedPlantId!);
    if (!mounted) return;
    setState(() => _isUsing = false);

    if (res.success) {
      Navigator.pop(context);
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("영양제를 사용했어요\n식물 친구가 좋아할 거예요")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text("어떤 식물에게 줄까요?", style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text("영양제를 줄 식물 친구를 골라주세요", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plants!.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        itemCount: _plants!.length,
                        itemBuilder: (context, index) {
                          final plant = _plants![index];
                          return SelectableUserPlantCard(
                            plant: plant,
                            isSelected: _selectedPlantId == plant.userPlantId,
                            onTap: () {
                              setState(() => _selectedPlantId = plant.userPlantId);
                            },
                          );
                        },
                      ),
            ),
            if (_plants != null && _plants!.isNotEmpty) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: "영양제 주기",
                isDisabled: _selectedPlantId == null,
                isLoading: _isUsing,
                onPressed: _useNutrient,
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.nature_people_outlined, size: 60, color: theme.disabledColor),
        const SizedBox(height: 16),
        Text("아직 돌볼 식물이 없어요", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("씨앗을 심고 첫 식물 친구를 만나보세요", style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        CustomButton(
          text: "씨앗 심기",
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SeedPlantingPage()));
          },
        )
      ],
    );
  }
}
