/// "Amina Hassan Mwangi" -> "AM"; single names use their first two letters.
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final only = parts.first;
    return only.substring(0, only.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
