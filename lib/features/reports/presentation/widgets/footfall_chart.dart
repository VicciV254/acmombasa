import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/report_models.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_card.dart';

/// Six-month stacked bar chart drawn with plain widgets (no chart package).
class FootfallChart extends StatelessWidget {
  const FootfallChart({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final bars = report.trend;
    final max = bars.fold<int>(1, (m, b) => b.total > m ? b.total : m);
    final prev = bars.length >= 2 ? bars[bars.length - 2].total : 0;
    final change = prev == 0 ? null : ((report.footfall - prev) / prev * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Monthly Visitor Footfall Trends', style: AppTextStyles.cardTitle)),
            _legend(AppColors.navy, 'Walk-in'),
            const SizedBox(width: 12),
            _legend(AppColors.brightBlue, 'Program Attendees'),
          ]),
          const Text('Visits per month, last six months', style: AppTextStyles.caption),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in bars)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(groupThousands(b.total),
                              style: AppTextStyles.caption.copyWith(
                                  fontWeight: b.isSelected ? FontWeight.w800 : FontWeight.w500)),
                          const SizedBox(height: 4),
                          Flexible(
                            child: LayoutBuilder(builder: (context, c) {
                              final h = c.maxHeight * (b.total / max);
                              final programH = b.total == 0 ? 0.0 : h * (b.programVisits / b.total);
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: Tooltip(
                                  message: '${b.label}: ${b.walkIns} walk-in, '
                                      '${b.programVisits} program',
                                  child: SizedBox(
                                    height: h,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: programH,
                                          color: b.isSelected
                                              ? AppColors.americanRed
                                              : AppColors.brightBlue.withValues(alpha: 0.55),
                                        ),
                                        Container(
                                          height: h - programH,
                                          color: b.isSelected ? AppColors.navy : AppColors.navy.withValues(alpha: 0.85),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(b.label,
                              style: AppTextStyles.caption.copyWith(
                                  fontWeight: b.isSelected ? FontWeight.w800 : FontWeight.w500,
                                  color: b.isSelected ? AppColors.americanRed : null)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: Text(
                change == null
                    ? 'No earlier month to compare'
                    : '${change >= 0 ? '+' : ''}$change% vs previous month',
                style: AppTextStyles.caption.copyWith(
                    color: (change ?? 0) >= 0 ? AppColors.success : AppColors.americanRed,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Text('Average Daily Visitors: ${report.dailyAverage.toStringAsFixed(1)} check-ins/day',
                style: AppTextStyles.caption),
          ]),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label) => Row(children: [
        Container(width: 10, height: 10, color: c),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ]);
}
