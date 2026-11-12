import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // Splash / sign-in (on dark background)
  static const TextStyle splashTitle = TextStyle(
    color: AppColors.white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 4,
    height: 1.2,
  );

  static const TextStyle splashSubtitle = TextStyle(
    color: AppColors.whiteMuted,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static const TextStyle splashError = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    height: 1.4,
  );

  // Staff console (on light background)
  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
    height: 1.35,
  );

  /// Small uppercase label used above values and as table headers.
  static const TextStyle label = TextStyle(
    color: AppColors.textMuted,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.3,
  );

  static const TextStyle statValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const TextStyle sidebarLabel = TextStyle(
    color: Color(0x8CFFFFFF),
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}
