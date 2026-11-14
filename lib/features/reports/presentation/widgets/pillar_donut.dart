import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/report_models.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_card.dart';

const _pillarColors = [
  AppColors.navy,
  AppColors.brightBlue,
  AppColors.americanRed,
  Color(0xFF0EA5A4),
  Color(0xFF94A3B8),
  Color(0xFFB45309),
];

class PillarDonut extends StatelessWidget {
  const PillarDonut({super.key, required this.report, required this.onLedger});

  final MonthlyReport report;
  final VoidCallback onLedger;

  @override
  Widget build(BuildContext context) {
    final pillars = report.pillars;
    final total = pillars.fold<int>(0, (a, p) => a + p.count);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Strategic Pillar Distribution', style: AppTextStyles.cardTitle),
          const Text('Mandated reporting basis for ECA standard term submissions',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: _DonutPainter([for (final p in pillars) p.count.toDouble()]),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${report.pillars.where((p) => p.count > 0).length}',
                        style: AppTextStyles.statValue),
                    const Text('PILLARS', style: AppTextStyles.label),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (total == 0)
            const Text('No program check-ins this month.', style: AppTextStyles.caption)
          else
            for (var i = 0; i < pillars.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Container(
                      width: 9, height: 9, color: _pillarColors[i % _pillarColors.length]),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(pillars[i].label,
                          overflow: TextOverflow.ellipsis, style: AppTextStyles.body)),
                  Text('${(pillars[i].fraction * 100).round()}%',
                      style: AppTextStyles.bodyStrong),
                ]),
              ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onLedger, child: const Text('Detailed Pillar Ledger')),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    final rect = Offset.zero & size;
    final stroke = size.width * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final area = rect.deflate(stroke / 2);

    if (total == 0) {
      paint.color = AppColors.neutralSoft;
      canvas.drawArc(area, 0, math.pi * 2, false, paint);
      return;
    }
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      if (values[i] == 0) continue;
      final sweep = values[i] / total * math.pi * 2;
      paint.color = _pillarColors[i % _pillarColors.length];
      canvas.drawArc(area, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.values != values;
}

Future<void> showPillarLedger(BuildContext context, MonthlyReport report) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Detailed Pillar Ledger'),
      content: SizedBox(
        width: 560,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1.4),
          },
          children: [
            const TableRow(children: [
              Padding(padding: EdgeInsets.all(6), child: Text('PILLAR', style: AppTextStyles.label)),
              Padding(padding: EdgeInsets.all(6), child: Text('VISITS', style: AppTextStyles.label)),
              Padding(padding: EdgeInsets.all(6), child: Text('SESSIONS', style: AppTextStyles.label)),
              Padding(padding: EdgeInsets.all(6), child: Text('UNIQUE PEOPLE', style: AppTextStyles.label)),
            ]),
            for (final l in report.ledger)
              TableRow(children: [
                Padding(padding: const EdgeInsets.all(6), child: Text(l.pillar, style: AppTextStyles.bodyStrong)),
                Padding(padding: const EdgeInsets.all(6), child: Text(groupThousands(l.visits))),
                Padding(padding: const EdgeInsets.all(6), child: Text('${l.sessions}')),
                Padding(padding: const EdgeInsets.all(6), child: Text('${l.uniqueAttendees}')),
              ]),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    ),
  );
}
