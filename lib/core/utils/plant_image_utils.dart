// ============================================================
// 식물 이미지 URL 선택 유틸
//
// 홈 화면: aiImageUrl 우선 (감성적 AI 이미지)
// 상세 화면: imageUrl 우선 (실제 스냅샷으로 식물 상태 확인)
// ============================================================

/// 홈 화면 카드 이미지 URL 결정
/// 우선순위: aiImageUrl → imageUrl → null(기본 아이콘)
String? getHomePlantImageUrl({
  required String? aiImageUrl,
  required String? originalImageUrl,
}) {
  if (aiImageUrl != null && aiImageUrl.isNotEmpty) return aiImageUrl;
  if (originalImageUrl != null && originalImageUrl.isNotEmpty) {
    return originalImageUrl;
  }
  return null;
}

/// 식물 상세 화면 대표 이미지 URL 결정
/// 우선순위: imageUrl → aiImageUrl → null(기본 아이콘)
String? getDetailPlantImageUrl({
  required String? aiImageUrl,
  required String? originalImageUrl,
}) {
  if (originalImageUrl != null && originalImageUrl.isNotEmpty) {
    return originalImageUrl;
  }
  if (aiImageUrl != null && aiImageUrl.isNotEmpty) return aiImageUrl;
  return null;
}
