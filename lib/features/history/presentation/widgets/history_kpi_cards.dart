import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/history_models.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pill.dart';

class HistoryKpiCards extends StatelessWidget {
  const HistoryKpiCards({super.key, required this.kpis});

  final HistoryKpis kpis;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _total()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _duration()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _patrons()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _peak()),
      ],
    );
  }

  Widget _card(String label, String value, Widget footer) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppTextStyles.label),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.statValue),
            const SizedBox(height: 8),
            footer,
          ],
        ),
      );

  Widget _total() {
    final prev = kpis.previousTotal;
    String text;
    Color bg = AppColors.neutralSoft;
    Color fg = AppColors.textSecondary;
    if (prev == 0) {
      text = kpis.total == 0 ? 'No visits' : 'No earlier period';
    } else {
      final pct = ((kpis.total - prev) / prev * 100).round();
      text = '${pct >= 0 ? '+' : ''}$pct% vs previous period';
      bg = pct >= 0 ? AppColors.successSoft : AppColors.dangerSoft;
      fg = pct >= 0 ? AppColors.success : AppColors.americanRed;
    }
    return _card('Total Visits', groupThousands(kpis.total),
        Pill(label: text, background: bg, foreground: fg));
  }

  Widget _duration() {
    final avg = kpis.avgMinutes;
    return _card(
      'Avg Visit Duration',
      avg == null ? '—' : formatMinutes(avg),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: kpis.checkedOutRate,
              minHeight: 6,
              backgroundColor: AppColors.neutralSoft,
              color: AppColors.brightBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kpis.medianMinutes == null
                ? 'No completed visits'
                : 'Median ${formatMinutes(kpis.medianMinutes!)} • '
                    '${(kpis.checkedOutRate * 100).round()}% checked out',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _patrons() => _card(
        'Unique Patrons',
        groupThousands(kpis.uniquePatrons),
        Wrap(spacing: 6, runSpacing: 4, children: [
          Pill(
            label: '${(kpis.returnRate * 100).round()}% return rate',
            background: AppColors.infoSoft,
            foreground: AppColors.info,
          ),
          Pill(label: '${kpis.firstTimeRegistrations} new'),
        ]),
      );

  Widget _peak() {
    final start = kpis.peakStartHour;
    if (start == null) {
      return _card('Peak Traffic Window', '—',
          const Text('No visits in range', style: AppTextStyles.caption));
    }
    final window = '${DateFormatter.minutesToTime12(start * 60)} – '
        '${DateFormatter.minutesToTime12((start + 2) * 60)}';
    final part = start < 12 ? 'Morning' : (start < 17 ? 'Afternoon' : 'Evening');
    return _card(
      'Peak Traffic Window',
      window,
      Wrap(spacing: 6, runSpacing: 4, children: [
        Pill(
            label: part,
            background: AppColors.warningSoft,
            foreground: AppColors.warning),
        Pill(label: 'Up to ${kpis.peakConcurrent} inside'),
      ]),
    );
  }
}
