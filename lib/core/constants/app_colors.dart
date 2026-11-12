import 'package:flutter/painting.dart';

/// American Corner brand colours plus the neutral/status palette used by the
/// staff console.
///
/// Brand values are close approximations of the official palette. Replace them
/// with the official hex codes if you have them; nothing else needs to change.
abstract final class AppColors {
  // Brand
  static const Color navy = Color(0xFF0A1F44);
  static const Color navyDeep = Color(0xFF06142E);
  static const Color brightBlue = Color(0xFF1E6FE0);
  static const Color americanRed = Color(0xFFB22234);
  static const Color white = Color(0xFFFFFFFF);

  /// Softer white used for secondary text on dark backgrounds.
  static const Color whiteMuted = Color(0xB3FFFFFF);

  // Surfaces
  static const Color pageBackground = Color(0xFFF1F5F9);
  static const Color surface = white;
  static const Color surfaceTinted = Color(0xFFF8FAFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Sidebar
  static const Color sidebar = Color(0xFF0B1F4A);
  static const Color sidebarFooter = Color(0xFF081738);
  static const Color sidebarText = Color(0xFFB6C2DA);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textFaint = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF15803D);
  static const Color successDot = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoSoft = Color(0xFFE3EDFF);
  static const Color neutralSoft = Color(0xFFF1F5F9);
  static const Color dangerSoft = Color(0xFFFEE2E2);
}
