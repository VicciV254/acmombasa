import 'dart:math';

/// Random 128-bit id as 32 hex characters. Safe to generate offline on any
/// terminal without clashing with other terminals.
String newId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
