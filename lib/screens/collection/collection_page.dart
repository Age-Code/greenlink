import 'package:flutter/material.dart';
import '../../models/collection_models.dart';
import '../../services/collection_service.dart';
import '../../core/widgets/greenlink_card.dart';
import 'collection_detail_page.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final CollectionService _collectionService = CollectionService();
  List<CollectionPlant>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    final res = await _collectionService.getCollections();
    if (res.success && res.data != null) {
      if (!mounted) return;
      setState(() {
        _items = res.data;
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _items = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("식물 도감"), centerTitle: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items == null || _items!.isEmpty
          ? _buildEmptyState(theme)
          : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              "함께한 식물 친구들이 기록돼요",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryCard(theme),
          const SizedBox(height: 24),
          _buildGridView(theme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    int totalCount = _items?.length ?? 0;
    int collectedCount = _items?.where((i) => i.collected).length ?? 0;
    int uncollectedCount = totalCount - collectedCount;

    return GreenlinkCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "만난 식물 $collectedCount개",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("전체 도감 $totalCount개", style: theme.textTheme.bodySmall),
                Text(
                  "아직 ${uncollectedCount}개의 식물을 기다리고 있어요",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_stories,
            size: 40,
            color: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final item = _items![index];
        return _buildPlantCard(item, theme);
      },
    );
  }

  Widget _buildPlantCard(CollectionPlant item, ThemeData theme) {
    final bool isCollected = item.collected;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailPage(plantId: item.plantId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCollected
              ? theme.scaffoldBackgroundColor
              : theme.disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCollected
                ? theme.colorScheme.secondary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isCollected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Opacity(
                opacity: isCollected ? 1.0 : 0.4,
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.contain)
                    : Icon(
                        Icons.local_florist,
                        size: 60,
                        color: theme.primaryColor,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCollected
                    ? theme.textTheme.titleLarge?.color
                    : theme.disabledColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (isCollected) ...[
              if (item.harvestCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "수확 ${item.harvestCount}회",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColorDark,
                    ),
                  ),
                )
              else
                Text(
                  "기록 완료",
                  style: TextStyle(fontSize: 12, color: theme.primaryColorDark),
                ),

              if (item.firstHarvestedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "처음 만난 날",
                    style: TextStyle(fontSize: 10, color: theme.disabledColor),
                  ),
                ),
            ] else ...[
              Text(
                "아직 만나지\n못했어요",
                style: TextStyle(fontSize: 12, color: theme.disabledColor),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: theme.disabledColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            "아직 도감에 등록된 식물이 없어요",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "식물을 키우고 수확하면 이곳에 기록돼요",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
