import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../services/plant_service.dart';
import '../models/plant.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';
import 'user_plant_list_page.dart';
import 'seed_planting_page.dart';
import 'user_plant_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService _homeService = HomeService();
  final PlantService _plantService = PlantService();
  
  Map<String, dynamic>? _homeData;
  List<UserPlant> _userPlants = [];
  bool _isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    final homeRes = await _homeService.getHomeData();
    if (!mounted) return;
    if (homeRes.success && homeRes.data != null) {
      _homeData = homeRes.data;
      
      // Try to load user plants for swipe view
      final plantsRes = await _plantService.getUserPlants(status: 'GROWING');
      if (!mounted) return;
      if (plantsRes.success && plantsRes.data != null) {
        _userPlants = plantsRes.data!;
      }
      
      // Ensure the main plant from home data is in the list, or just use the plants list
      if (_userPlants.isEmpty && _homeData!['mainUserPlant'] != null) {
        final mainP = _homeData!['mainUserPlant'];
        _userPlants.add(UserPlant(
          userPlantId: mainP['userPlantId'],
          plantId: 0,
          plantName: mainP['plantName'],
          nickname: mainP['nickname'],
          status: mainP['status'],
          imageUrl: mainP['imageUrl'],
          plantedAt: mainP['plantedAt'],
          daysAfterPlanting: mainP['daysAfterPlanting'],
          remainingDays: mainP['remainingDays']
        ));
      }
    }
    setState(() => _isLoading = false);
  }

  void _harvestPlant(UserPlant plant) async {
    final res = await _plantService.harvestUserPlant(plant.userPlantId);
    if (!mounted) return;
    
    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("수확이 완료되었습니다!")));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_homeData == null) {
      return const Center(child: Text("데이터를 불러오지 못했습니다."));
    }

    final user = _homeData!['user'];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("안녕, ${user['nickname']}", style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text("오늘도 식물 친구를 살펴볼까요?", style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Material(
                  color: theme.colorScheme.surface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: IconButton(
                    icon: Icon(Icons.format_list_bulleted, color: theme.primaryColor),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UserPlantListPage()));
                    },
                    tooltip: '내 식물 목록',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Main Center Area (Plant Cards)
          Expanded(
            child: _userPlants.isEmpty
                ? _buildEmptyPlantCard(theme)
                : _buildPlantCarousel(theme),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyPlantCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: CustomCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist_outlined, size: 100, color: theme.colorScheme.secondary),
            const SizedBox(height: 24),
            Text("아직 함께하는 식물이 없어요", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("씨앗을 심고 첫 식물 친구를 만나보세요", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            CustomButton(
              text: "씨앗 심기",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SeedPlantingPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCarousel(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _userPlants.length,
            itemBuilder: (context, index) {
              final plant = _userPlants[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * MediaQuery.of(context).size.height * 0.6,
                      width: Curves.easeOut.transform(value) * MediaQuery.of(context).size.width,
                      child: child,
                    ),
                  );
                },
                child: _buildPlantCard(plant, theme),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicator
        if (_userPlants.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_userPlants.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentPage == index ? 12.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: _currentPage == index ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: _currentPage == index ? BorderRadius.circular(4.0) : null,
                  color: _currentPage == index ? theme.primaryColor : theme.colorScheme.surface,
                  border: _currentPage == index ? null : Border.all(color: theme.disabledColor.withOpacity(0.3)),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildPlantCard(UserPlant plant, ThemeData theme) {
    String statusText = "";
    String remainingText = "";
    bool canHarvest = false;

    if (plant.status == "GROWING") {
      statusText = "조금씩 자라고 있어요";
      remainingText = "수확까지 ${plant.remainingDays ?? 0}일 남았어요";
    } else if (plant.status == "HARVESTABLE") {
      statusText = "수확할 준비가 되었어요";
      if ((plant.remainingDays ?? 0) == 0) {
        remainingText = "오늘 수확할 수 있어요";
        canHarvest = true;
      } else {
        remainingText = "수확까지 ${plant.remainingDays ?? 0}일 남았어요";
      }
    } else if (plant.status == "HARVESTED") {
      statusText = "함께한 시간이 도감에 기록됐어요";
      remainingText = "수확을 마친 식물이에요";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: CustomCard(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => UserPlantDetailPage(userPlantId: plant.userPlantId)));
        },
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Status Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(statusText, style: TextStyle(color: theme.primaryColorDark, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            
            // Plant Image (Placeholder)
            Expanded(
              child: plant.imageUrl != null 
                ? Image.network(plant.imageUrl!, fit: BoxFit.contain)
                : Icon(Icons.eco, size: 120, color: theme.primaryColor),
            ),
            
            const SizedBox(height: 24),
            
            // Info
            Text(plant.nickname, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(plant.plantName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
            const SizedBox(height: 16),
            Text(remainingText, style: theme.textTheme.bodyMedium),
            
            // Harvest Button if applicable
            if (canHarvest) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: "수확하기",
                onPressed: () => _harvestPlant(plant),
              )
            ]
          ],
        ),
      ),
    );
  }
}
