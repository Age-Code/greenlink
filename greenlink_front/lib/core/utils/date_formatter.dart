class DateFormatter {
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  static String formatDateKorean(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}년 ${dt.month}월 ${dt.day}일';
    } catch (e) {
      return isoString;
    }
  }
}
