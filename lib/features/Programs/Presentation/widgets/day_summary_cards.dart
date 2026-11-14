import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/program_models.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pill.dart';

class DaySummaryCards extends StatelessWidget {
  const DaySummaryCards({super.key, required this.summary, required this.isToday});

  final DaySummary summary;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _card(
            isToday ? "TODAY'S SCHEDULE" : 'SCHEDULE',
            Icons.calendar_today_outlined,
            RichText(
              text: TextSpan(children: [
                TextSpan(text: '${s.sessions}', style: AppTextStyles.statValue),
                TextSpan(
                    text: ' Session${s.sessions == 1 ? '' : 's'}',
                    style: AppTextStyles.bodyStrong),
              ]),
            ),
            Wrap(spacing: 6, runSpacing: 4, children: [
              if (s.ongoing > 0)
                Pill(
                  label: '${s.ongoing} Ongoing Now',
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                ),
              if (s.ongoingRoom != null)
                Text('in ${s.ongoingRoom}', style: AppTextStyles.caption),
              if (s.ongoing == 0) const Text('Nothing running right now', style: AppTextStyles.caption),
            ]),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _card(
            'PRE-REGISTERED',
            Icons.how_to_reg_outlined,
            RichText(
              text: TextSpan(children: [
                TextSpan(text: '${s.preRegistered}', style: AppTextStyles.statValue),
                const TextSpan(text: ' Attendees', style: AppTextStyles.bodyStrong),
              ]),
            ),
            Text(
              '${s.walkIns} walk-in${s.walkIns == 1 ? '' : 's'} admitted • '
              '${s.seatsTotal} seats scheduled',
              style: AppTextStyles.caption,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _card(
            'HALL & LAB OCCUPANCY',
            Icons.meeting_room_outlined,
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: '${(s.occupancy * 100).round()}%',
                    style: AppTextStyles.statValue),
                const TextSpan(text: ' Capacity', style: AppTextStyles.bodyStrong),
              ]),
            ),
            Text(
              '${s.seatsReserved} / ${s.seatsTotal} seats reserved'
              '${s.rooms.isEmpty ? '' : ' in ${s.rooms.take(2).join(' & ')}'}',
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _card(
            'FLAGSHIP ANCHOR',
            Icons.star_outline,
            Text(s.flagshipName ?? 'No sessions yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle),
            Text(
              s.flagshipName == null
                  ? 'Appears after the first check-ins'
                  : '${s.flagshipAverage} avg. participants per session (30 days)',
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(String label, IconData icon, Widget value, Widget footer) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(label, style: AppTextStyles.label)),
              Icon(icon, size: 16, color: AppColors.brightBlue),
            ]),
            const SizedBox(height: 8),
            value,
            const SizedBox(height: 8),
            footer,
          ],
        ),
      );
}
