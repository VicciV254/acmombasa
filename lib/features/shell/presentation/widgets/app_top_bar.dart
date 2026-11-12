import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/pill.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.compact = false});

  static const double height = 68;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _Brand(compact: compact),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _StatusCluster(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const _UserBadge(),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.desktop_windows_outlined,
            color: AppColors.white,
            size: 22,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 168,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'American Corner Mombasa',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong
                      .copyWith(fontSize: 13.5, height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  'Part of American Spaces Global Network',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusCluster extends StatelessWidget {
  const _StatusCluster();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Pill(label: 'VISITOR MANAGEMENT'),
        SizedBox(width: 12),
        _DateTimeCapsule(),
        SizedBox(width: 12),
        Pill(
          label: 'Local Database Connected (Offline Sync Active)',
          background: AppColors.successSoft,
          foreground: AppColors.success,
          dotColor: AppColors.successDot,
        ),
      ],
    );
  }
}

class _DateTimeCapsule extends StatefulWidget {
  const _DateTimeCapsule();

  @override
  State<_DateTimeCapsule> createState() => _DateTimeCapsuleState();
}

class _DateTimeCapsuleState extends State<_DateTimeCapsule> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(DateFormatter.fullDate(_now), style: style),
          Container(
            width: 1,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: AppColors.borderStrong,
          ),
          const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text('${DateFormatter.time12(_now)} EAT', style: style),
        ],
      ),
    );
  }
}

class _UserBadge extends StatelessWidget {
  const _UserBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Fatuma Ali', style: AppTextStyles.bodyStrong),
            Text('Lead Receptionist',
                style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
        const SizedBox(width: 10),
        const InitialsAvatar(
          initials: 'FA',
          size: 38,
          background: AppColors.brightBlue,
        ),
      ],
    );
  }
}
