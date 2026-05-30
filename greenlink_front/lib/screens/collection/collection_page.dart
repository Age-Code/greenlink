import 'package:flutter/material.dart';
import '../../models/collection_models.dart';
import '../../services/collection_service.dart';
import '../../core/widgets/greenlink_card.dart';
import '../../theme/app_theme.dart';
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
      setState(() { _items = res.data; _isLoading = false; });
    } else {
      if (!mounted) return;
      setState(() { _items = []; _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('식물 도감'), centerTitle: false),
      body: _isLoading
          ? const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryStrong)))
          : _items == null || _items!.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('함께한 식물 친구들이 기록돼요', style: TextStyle(fontSize: 15, color: AppColors.bodyMuted)),
          const SizedBox(height: 20),
          _buildSummaryCard(),
          const SizedBox(height: 24),
          const Text('전체 도감', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(height: 16),
          _buildGridView(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    int totalCount = _items?.length ?? 0;
    int collectedCount = _items?.where((i) => i.collected).length ?? 0;
    int uncollectedCount = totalCount - collectedCount;

    return GreenlinkCard(
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.auto_stories_rounded, size: 28, color: AppColors.primaryStrong),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '만난 식물 $collectedCount종',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.2),
                ),
                const SizedBox(height: 4),
                Text('전체 $totalCount종 중 · 아직 $uncollectedCount종을 기다리고 있어요', style: const TextStyle(fontSize: 13, color: AppColors.bodyMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) => _buildPlantCard(_items![index]),
    );
  }

  Widget _buildPlantCard(CollectionPlant item) {
    final bool isCollected = item.collected;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CollectionDetailPage(plantId: item.plantId))),
      child: Container(
        decoration: BoxDecoration(
          color: isCollected ? AppColors.surfaceCard : AppColors.canvasSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCollected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.hairline,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Opacity(
                opacity: isCollected ? 1.0 : 0.35,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isCollected ? AppColors.canvasSoft : AppColors.canvasSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.imageUrl != null
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.network(item.imageUrl!, fit: BoxFit.contain),
                        )
                      : Icon(Icons.local_florist_rounded, size: 48, color: isCollected ? AppColors.primaryStrong : AppColors.bodySoft),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              item.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCollected ? AppColors.ink : AppColors.bodyMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Status
            if (isCollected) ...[
              if (item.harvestCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '수확 ${item.harvestCount}회',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primaryStrong),
                  ),
                )
              else
                const Text('기록 완료', style: TextStyle(fontSize: 12, color: AppColors.primaryStrong)),
            ] else ...[
              const Text('아직 만나지 못했어요', style: TextStyle(fontSize: 12, color: AppColors.bodySoft), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.canvasGreenTint, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.menu_book_rounded, size: 40, color: AppColors.bodyMuted),
            ),
            const SizedBox(height: 24),
            const Text('아직 도감에 등록된 식물이 없어요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink)),
            const SizedBox(height: 8),
            const Text('식물을 키우고 수확하면 이곳에 기록돼요', style: TextStyle(fontSize: 14, color: AppColors.bodyMuted, height: 1.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
