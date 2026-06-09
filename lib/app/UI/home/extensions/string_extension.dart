extension StringExtension on String {
  String get fallbackLabel {
    final parts =
        trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';
    return '${first[0]}${last.isNotEmpty ? last[0] : ''}'.toUpperCase();
  }
}
