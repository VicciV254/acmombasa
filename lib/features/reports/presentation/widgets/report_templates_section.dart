import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pill.dart';

class ReportTemplate {
  const ReportTemplate({
    required this.badge,
    required this.frequency,
    required this.title,
    required this.description,
    required this.run,
  });

  final String badge;
  final String frequency;
  final String title;
  final String description;
  final Future<void> Function() run;
}

class ReportTemplatesSection extends StatefulWidget {
  const ReportTemplatesSection({super.key, required this.templates});

  final List<ReportTemplate> templates;

  @override
  State<ReportTemplatesSection> createState() => _ReportTemplatesSectionState();
}

class _ReportTemplatesSectionState extends State<ReportTemplatesSection> {
  String? _running;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pre-Configured Compliance & Operational Templates',
              style: AppTextStyles.cardTitle),
          const Text('Standardized templates aligned with Bureau of Educational & Cultural Affairs formats',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t in widget.templates)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTinted,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Pill(
                              label: t.badge,
                              background: AppColors.infoSoft,
                              foreground: AppColors.info,
                              fontSize: 9.5),
                          const Spacer(),
                          Text(t.frequency, style: AppTextStyles.caption),
                        ]),
                        const SizedBox(height: 8),
                        Text(t.title, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(t.description, style: AppTextStyles.caption),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _running != null
                              ? null
                              : () async {
                                  setState(() => _running = t.title);
                                  try {
                                    await t.run();
                                  } finally {
                                    if (mounted) setState(() => _running = null);
                                  }
                                },
                          style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: Text(_running == t.title ? 'Running…' : 'Run Report'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
