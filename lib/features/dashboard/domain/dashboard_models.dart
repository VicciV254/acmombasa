import 'package:flutter/widgets.dart';

enum FooterTone { positive, neutral }

class StatCardData {
  const StatCardData({
    required this.label,
    required this.icon,
    required this.value,
    required this.unit,
    required this.footer,
    this.tone = FooterTone.neutral,
    this.progress,
    this.live = false,
  });

  final String label;
  final IconData icon;
  final String value;
  final String unit;
  final String footer;
  final FooterTone tone;

  /// 0..1; draws a thin progress bar under the value when set.
  final double? progress;

  /// Shows a small "live" dot next to the label.
  final bool live;
}
