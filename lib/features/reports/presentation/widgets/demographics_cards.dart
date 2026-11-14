import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/report_models.dart';
import '../../../../core/widgets/app_card.dart';

class ResidenceCard extends StatelessWidget {
  const ResidenceCard({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final rows = report.residence;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Audience Residence Distribution', style: AppTextStyles.cardTitle)),
            Text('${report.residenceRecorded} recorded', style: AppTextStyles.caption),
          ]),
          const Text('Sub-county / area of residence of visitors this month',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text('No residence data recorded yet.', style: AppTextStyles.caption)
          else
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(r.label, style: AppTextStyles.bodyStrong)),
                    Text('${(r.fraction * 100).round()}% (${r.count} visitors)',
                        style: AppTextStyles.caption),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: r.fraction,
                      minHeight: 6,
                      backgroundColor: AppColors.neutralSoft,
                      color: AppColors.brightBlue,
                    ),
                  ),
                ]),
              ),
          if (rows.length >= 2)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'Outreach note: ${rows.last.label} contributes the smallest share of the top five areas '
                '(${(rows.last.fraction * 100).round()}%).',
                style: AppTextStyles.caption.copyWith(color: AppColors.info),
              ),
            ),
        ],
      ),
    );
  }
}

class AgeCohortCard extends StatelessWidget {
  const AgeCohortCard({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final cohorts = report.cohorts;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Text('Age Cohort Demographics', style: AppTextStyles.cardTitle)),
            Text('${report.ageRecorded} recorded', style: AppTextStyles.caption),
          ]),
          const Text('Age profile distribution for quarterly ECA reporting',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
            children: [
              for (var i = 0; i < cohorts.length; i++)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: i == 1 ? AppColors.infoSoft : AppColors.surfaceTinted,
                    border: Border.all(
                        color: i == 1 ? AppColors.brightBlue : AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cohorts[i].label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label),
                      Text('${(cohorts[i].fraction * 100).round()}%',
                          style: AppTextStyles.statValue.copyWith(fontSize: 24)),
                      Text('${cohorts[i].count} visitors', style: AppTextStyles.caption),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
