import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pill.dart';
import '../../data/dashboard_sample_data.dart';
import '../../domain/dashboard_models.dart';

class TodaysActivitiesCard extends StatelessWidget {
  const TodaysActivitiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available_outlined,
                  size: 22, color: AppColors.brightBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text("Today's Activities",
                    style: AppTextStyles.cardTitle),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Pill(
                  label: 'HAPPENING NOW',
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                  dotColor: AppColors.successDot,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Scheduled program roster for Mombasa Hub spaces and lab '
            'facilities.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in DashboardSampleData.activities) _ActivityTile(item),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.neutralSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text('Total Scheduled Engagement',
                      style: AppTextStyles.bodyStrong),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Pill(
                    label: DashboardSampleData.totalEngagement,
                    background: AppColors.navy,
                    foreground: AppColors.white,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _CapacityBanner(),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile(this.item);

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isActive ? AppColors.surfaceTinted : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg - 2),
        border: Border.all(
          color: item.isActive
              ? AppColors.brightBlue.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(item.icon, size: 18, color: AppColors.brightBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.title, style: AppTextStyles.bodyStrong),
                    ),
                    const SizedBox(width: 8),
                    Pill(
                      label: item.badge,
                      background: AppColors.infoSoft,
                      foreground: AppColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(item.schedule, style: AppTextStyles.caption),
                if (item.note != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.isActive
                              ? AppColors.successDot
                              : AppColors.textFaint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.note!,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: item.isActive
                                ? AppColors.success
                                : AppColors.textMuted,
                            fontWeight: item.isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stand-in for the photo banner in the reference design (no image asset
/// available): a branded gradient with the capacity note.
class _CapacityBanner extends StatelessWidget {
  const _CapacityBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg - 2),
      child: Container(
        height: 96,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.navy, Color(0xFF1B4F9C)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                Icons.meeting_room_outlined,
                size: 110,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            const Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                'Room A & Lab 2 near max for peak sessions',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
