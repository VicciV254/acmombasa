import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill.dart';

/// Clearly-labelled stand-in for modules that are not built yet.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: AppColors.textFaint),
                const SizedBox(height: AppSpacing.md),
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.sm),
                const Pill(
                  label: 'TEMPORARY PLACEHOLDER',
                  background: AppColors.dangerSoft,
                  foreground: AppColors.americanRed,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'This module has not been built yet.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
