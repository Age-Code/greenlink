import 'package:flutter/material.dart';
import '../../models/home_models.dart';
import '../../models/iot_models.dart';
import '../../services/home_service.dart';
import '../../services/user_plant_service.dart';
import '../../services/iot_service.dart';
import '../../models/user_plant_models.dart';
import '../../core/utils/plant_image_utils.dart';
import '../../core/widgets/greenlink_card.dart';
import '../../core/widgets/greenlink_button.dart';
import '../user_plant/user_plant_list_page.dart';
import '../user_plant/seed_planting_page.dart';
import '../user_plant/user_plant_detail_page.dart';
import '../settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomeService _homeService = HomeService();
  final UserPlantService _plantService = UserPlantService();
  final IotService _iotService = IotService();

  HomeResponse? _homeData;
  List<UserPlantSummary> _userPlants = [];
  // userPlantId → IoT latest 이미지 정보 (aiImageUrl + imageUrl)
  final Map<int, PlantImageData?> _latestImageData = {};
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

  /// 3. 홈 화면 갱신 — 외부에서 호출 가능한 refresh
  void refresh() {
    debugPrint('[HomePage] 🔄 refresh home');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // GET /api/home — user 정보 + 대표 식물 1개
    final homeRes = await _homeService.getHomeData();
    if (!mounted) return;

    if (homeRes.success && homeRes.data != null) {
      _homeData = homeRes.data;

      // GET /api/user-plants — GROWING + HARVESTABLE만 캐러셀에 표시
      final plantsRes = await _plantService.getUserPlants();
      if (!mounted) return;
      if (plantsRes.success && plantsRes.data != null) {
        _userPlants = plantsRes.data!
            .where((p) => p.status == 'GROWING' || p.status == 'HARVESTABLE')
            .toList();
      }

      // 목록이 비어 있지만 홈 API의 대표 식물이 있으면 폴백으로 표시
      if (_userPlants.isEmpty && _homeData!.mainUserPlant != null) {
        final plant = _homeData!.mainUserPlant!;
        if (plant.status == 'GROWING' || plant.status == 'HARVESTABLE') {
          _userPlants.add(UserPlantSummary(
            userPlantId: plant.userPlantId,
            plantId: plant.plantId,
            plantName: plant.plantName,
            nickname: plant.nickname,
            status: plant.status,
            imageUrl: plant.imageUrl,
            daysAfterPlanting: plant.daysAfterPlanting,
            remainingDays: plant.remainingDays,
          ));
        }
      }

      // 각 식물의 최신 이미지 정보 병렬 조회 (IoT latest API)
      if (_userPlants.isNotEmpty) {
        debugPrint('[HomePage] 📸 최신 이미지 병렬 조회 (${_userPlants.length}개)');
        final futures = _userPlants.map(
          (p) => _iotService.getLatestImageData(p.userPlantId).then(
                (data) => MapEntry(p.userPlantId, data),
              ),
        );
        final results = await Future.wait(futures);
        if (!mounted) return;
        for (final entry in results) {
          _latestImageData[entry.key] = entry.value;
        }
        debugPrint('[HomePage] ✅ 최신 이미지 로드 완료');
      }
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _harvestPlant(UserPlantSummary plant) async {
    final res = await _plantService.harvestUserPlant(plant.userPlantId);
    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("수확이 완료되었습니다!")));
      _loadData();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.message)));
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

    final user = _homeData!.user;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Area
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("안녕, ${user.nickname}",
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text("오늘도 식물 친구를 살펴볼까요?",
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Material(
                      color: theme.colorScheme.surface,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        icon: Icon(Icons.format_list_bulleted,
                            color: theme.primaryColor),
                        onPressed: () async {
                          // 2. 식물 목록에서 돌아왔을 때 홈 갱신
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserPlantListPage()),
                          );
                          if (!mounted) return;
                          if (result == true) {
                            debugPrint('[HomePage] 🔄 refresh home (after plant list)');
                            _loadData();
                          }
                        },
                        tooltip: '내 식물 목록',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()),
                        );
                      },
                      child: user.profileImageUrl != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(user.profileImageUrl!),
                              backgroundColor: theme.colorScheme.surface,
                            )
                          : Material(
                              color: theme.colorScheme.surface,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.person_outline,
                                    color: theme.primaryColor),
                              ),
                            ),
                    ),
                  ],
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
      child: GreenlinkCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist_outlined,
                size: 100, color: theme.colorScheme.secondary),
            const SizedBox(height: 24),
            Text("아직 함께하는 식물이 없어요",
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("씨앗을 심고 첫 식물 친구를 만나보세요",
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            GreenlinkButton(
              text: "씨앗 심기",
              onPressed: () async {
                // A. 씨앗 심기 성공 후 홈 갱신
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SeedPlantingPage()),
                );
                if (!mounted) return;
                if (result == true) {
                  debugPrint('[HomePage] 🔄 refresh home (after seed planting)');
                  _loadData();
                }
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
                      height: Curves.easeOut.transform(value) *
                          MediaQuery.of(context).size.height *
                          0.6,
                      width: Curves.easeOut.transform(value) *
                          MediaQuery.of(context).size.width,
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
                  shape: _currentPage == index
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: _currentPage == index
                      ? BorderRadius.circular(4.0)
                      : null,
                  color: _currentPage == index
                      ? theme.primaryColor
                      : theme.colorScheme.surface,
                  border: _currentPage == index
                      ? null
                      : Border.all(
                          color:
                              theme.disabledColor.withValues(alpha: 0.3)),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildPlantCard(UserPlantSummary plant, ThemeData theme) {
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
      child: GreenlinkCard(
        onTap: () async {
          // E. 식물 상세에서 수확 후 홈 갱신
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    UserPlantDetailPage(userPlantId: plant.userPlantId)),
          );
          if (!mounted) return;
          if (result == true) {
            debugPrint('[HomePage] 🔄 refresh home (after plant detail)');
            _loadData();
          }
        },
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Status Bubble
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(statusText,
                  style: TextStyle(
                      color: theme.primaryColorDark,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            // Plant Image — 홈 정책: aiImageUrl → imageUrl → 기본 아이콘
            Expanded(
              child: Builder(builder: (context) {
                final imgData = _latestImageData[plant.userPlantId];
                final displayUrl = getHomePlantImageUrl(
                  aiImageUrl: imgData?.aiImageUrl,
                  originalImageUrl: imgData?.imageUrl,
                );
                if (displayUrl != null) {
                  return Image.network(
                    displayUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.eco, size: 120, color: theme.primaryColor),
                  );
                }
                return Icon(Icons.eco, size: 120, color: theme.primaryColor);
              }),
            ),

            const SizedBox(height: 24),

            // Info
            Text(plant.nickname, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(plant.plantName,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.textTheme.bodySmall?.color)),
            const SizedBox(height: 16),
            Text(remainingText, style: theme.textTheme.bodyMedium),

            // Harvest Button if applicable
            if (canHarvest) ...[
              const SizedBox(height: 24),
              GreenlinkButton(
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
