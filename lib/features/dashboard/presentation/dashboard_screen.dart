import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/pill.dart';
import '../../../core/widgets/preview_notice.dart';
import '../data/dashboard_sample_data.dart';
import 'widgets/find_visitor_card.dart';
import 'widgets/recent_checkins_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/todays_activities_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const double _gap = 20;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 700 ? 16.0 : 24.0;
        final inner = constraints.maxWidth - padding * 2;
        final twoColumns = inner >= 980;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WelcomeHeader(stacked: inner < 760),
              const SizedBox(height: _gap),
              _StatsGrid(width: inner),
              const SizedBox(height: _gap),
              if (twoColumns)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: FindVisitorCard()),
                    SizedBox(width: _gap),
                    Expanded(flex: 4, child: TodaysActivitiesCard()),
                  ],
                )
              else ...const [
                FindVisitorCard(),
                SizedBox(height: _gap),
                TodaysActivitiesCard(),
              ],
              const SizedBox(height: _gap),
              const RecentCheckInsCard(),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Welcome back, Receptionist', style: AppTextStyles.pageTitle),
            Pill(
              label: 'ACTIVE SESSION',
              background: AppColors.infoSoft,
              foreground: AppColors.info,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Front Desk Terminal • Entrance Station 1 • American Corner '
          'Mombasa (KNLS Buruhani)',
          style: AppTextStyles.caption.copyWith(fontSize: 12.5),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () => showPreviewNotice(context),
          icon: const Icon(Icons.sync, size: 18),
          label: const Text('Sync Queue (0)'),
        ),
        FilledButton.icon(
          onPressed: () => showPreviewNotice(context),
          icon: const Icon(Icons.tv_outlined, size: 18),
          label: const Text('Batch Kiosk Mode'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
        ),
      ],
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: AppSpacing.md), actions],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: title),
        const SizedBox(width: AppSpacing.md),
        actions,
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.width});

  final double width;

  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    final stats = DashboardSampleData.stats;
    final columns = width >= 900 ? 4 : (width >= 520 ? 2 : 1);

    if (columns == 4) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Expanded(child: StatCard(data: stats[i])),
            ],
          ],
        ),
      );
    }

    final itemWidth = (width - _gap * (columns - 1)) / columns;
    return Wrap(
      spacing: _gap,
      runSpacing: _gap,
      children: [
        for (final stat in stats)
          SizedBox(width: itemWidth, child: StatCard(data: stat)),
      ],
    );
  }
}
