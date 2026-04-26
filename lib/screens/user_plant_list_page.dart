import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../widgets/custom_card.dart';
import 'user_plant_detail_page.dart';
import 'seed_planting_page.dart';

class UserPlantListPage extends StatefulWidget {
  @override
  _UserPlantListPageState createState() => _UserPlantListPageState();
}

class _UserPlantListPageState extends State<UserPlantListPage> {
  final PlantService _plantService = PlantService();
  
  List<UserPlant>? _plants;
  bool _isLoading = true;
  String _selectedStatus = 'ALL';

  final Map<String, String> _statusFilters = {
    'ALL': '전체',
    'GROWING': '성장 중',
    'HARVESTABLE': '수확 가능',
    'HARVESTED': '수확 완료',
  };

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    
    final statusParam = _selectedStatus == 'ALL' ? null : _selectedStatus;
    final res = await _plantService.getUserPlants(status: statusParam);
    
    if (!mounted) return;
    
    if (res.success && res.data != null) {
      setState(() {
        _plants = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _plants = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadPlants();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("내 식물"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SeedPlantingPage()),
          );
          if (result == true) {
            _loadPlants(); // 새로 심었으면 새로고침
          }
        },
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.primaryColorDark,
        icon: const Icon(Icons.add),
        label: const Text("씨앗 심기", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "함께 자라는 식물 친구들이에요",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilters(theme),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plants == null || _plants!.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.separated(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                        itemCount: _plants!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildPlantCard(_plants![index], theme);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildPlantCard(UserPlant plant, ThemeData theme) {
    String statusText;
    Color statusColor;
    
    switch (plant.status) {
      case 'GROWING':
        statusText = '자라는 중';
        statusColor = theme.primaryColorDark;
        break;
      case 'HARVESTABLE':
        statusText = '수확 가능';
        statusColor = theme.colorScheme.secondary;
        break;
      case 'HARVESTED':
        statusText = '수확 완료';
        statusColor = theme.disabledColor;
        break;
      default:
        statusText = plant.status;
        statusColor = theme.disabledColor;
    }

    String remainingText = '';
    if (plant.status == 'HARVESTED') {
      remainingText = '수확 완료';
    } else if (plant.remainingDays != null) {
      if (plant.remainingDays! > 0) {
        remainingText = '수확까지 ${plant.remainingDays}일';
      } else if (plant.remainingDays! <= 0 && plant.status == 'HARVESTABLE') {
        remainingText = '오늘 수확 가능';
      }
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserPlantDetailPage(userPlantId: plant.userPlantId)),
        );
        if (result == true) {
          _loadPlants();
        }
      },
      child: Opacity(
        opacity: plant.status == 'HARVESTED' ? 0.7 : 1.0,
        child: CustomCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: plant.imageUrl != null
                    ? Image.network(plant.imageUrl!)
                    : Icon(Icons.eco, size: 40, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                        if (plant.status == 'HARVESTABLE') ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: theme.colorScheme.secondary),
                        ]
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(plant.nickname, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(plant.plantName, style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor)),
                  ],
                ),
              ),
              if (remainingText.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      remainingText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: plant.status == 'HARVESTABLE' ? theme.colorScheme.secondary : theme.disabledColor,
                      ),
                    ),
                  ],
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
          Icon(Icons.yard_outlined, size: 80, color: theme.disabledColor.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text("아직 키우는 식물이 없어요", style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor)),
          const SizedBox(height: 8),
          Text("씨앗을 심고 첫 식물 친구를 만나보세요", style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor)),
        ],
      ),
    );
  }
}
