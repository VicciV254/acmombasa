import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/report_models.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pill.dart';

class ReportKpiCards extends StatelessWidget {
  const ReportKpiCards({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final r = report;
    final delta = r.target == 0 ? 0 : ((r.footfall - r.target) / r.target * 100).round();
    final reached = r.footfall >= r.target;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _card(
            'MONTHLY FOOTFALL TARGET',
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(groupThousands(r.footfall), style: AppTextStyles.statValue),
              const SizedBox(width: 6),
              Text('/ ${groupThousands(r.target)} goal', style: AppTextStyles.caption),
              const Spacer(),
              Pill(
                label: '${delta >= 0 ? '+' : ''}$delta%',
                background: reached ? AppColors.successSoft : AppColors.warningSoft,
                foreground: reached ? AppColors.success : AppColors.warning,
              ),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _bar(r.targetProgress.clamp(0, 1).toDouble(), AppColors.brightBlue),
              const SizedBox(height: 4),
              Text(
                reached
                    ? 'Target reached (${groupThousands(r.footfall)})'
                    : '${groupThousands(r.target - r.footfall)} visits to go',
                style: AppTextStyles.caption,
              ),
            ]),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _card(
            'GENDER INCLUSIVITY',
            Row(children: [
              Text(r.genderRecorded == 0 ? '—' : '${(r.femaleShare * 100).round()}%',
                  style: AppTextStyles.statValue),
              const SizedBox(width: 6),
              const Text('Female', style: AppTextStyles.caption),
              const SizedBox(width: 10),
              Text(r.genderRecorded == 0 ? '' : '${(r.maleShare * 100).round()}% Male',
                  style: AppTextStyles.caption),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _bar(r.femaleShare, AppColors.americanRed),
              const SizedBox(height: 4),
              Text(
                r.genderRecorded == 0
                    ? 'No gender data recorded yet'
                    : 'Based on ${r.genderRecorded} visitors with gender recorded',
                style: AppTextStyles.caption,
              ),
            ]),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _card(
            'YOUTH ENGAGEMENT RATIO',
            Row(children: [
              Text(r.ageRecorded == 0 ? '—' : '${(r.youthShare * 100).round()}%',
                  style: AppTextStyles.statValue),
              const SizedBox(width: 6),
              const Text('Ages 18-35', style: AppTextStyles.caption),
            ]),
            Text(
              r.ageRecorded == 0
                  ? 'No age data recorded yet'
                  : '${r.youth} young patrons of ${r.ageRecorded} with age recorded',
              style: AppTextStyles.caption,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _card(
            'EDUCATIONUSA & LIBRARY',
            Row(children: [
              Text(groupThousands(r.educationUsaVisits), style: AppTextStyles.statValue),
              const SizedBox(width: 6),
              const Text('Visits', style: AppTextStyles.caption),
            ]),
            Text('${r.educationUsaAttendees} unique attendees this month',
                style: AppTextStyles.caption),
          ),
        ),
      ],
    );
  }

  Widget _bar(double value, Color color) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: AppColors.neutralSoft,
          color: color,
        ),
      );

  Widget _card(String label, Widget value, Widget footer) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: 8),
            value,
            const SizedBox(height: 10),
            footer,
          ],
        ),
      );
}
