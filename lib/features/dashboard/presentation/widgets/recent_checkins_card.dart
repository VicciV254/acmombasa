import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/pill.dart';
import '../../../../core/widgets/preview_notice.dart';
import '../../data/dashboard_sample_data.dart';
import '../../domain/dashboard_models.dart';

enum _LogFilter { all, insideNow, checkedOut }

class RecentCheckInsCard extends StatefulWidget {
  const RecentCheckInsCard({super.key});

  @override
  State<RecentCheckInsCard> createState() => _RecentCheckInsCardState();
}

class _RecentCheckInsCardState extends State<RecentCheckInsCard> {
  static const double _minTableWidth = 900;
  // Column flex values: name, card, time, purpose, status, actions.
  static const List<int> _flex = [28, 18, 14, 22, 20, 18];
  static const List<String> _headers = [
    'VISITOR NAME',
    'ID / CARD NUMBER',
    'CHECK-IN TIME',
    'VISIT PURPOSE',
    'STATUS',
    'ACTIONS',
  ];

  _LogFilter _filter = _LogFilter.all;

  List<CheckInRecord> get _rows {
    final all = DashboardSampleData.recentCheckIns;
    return switch (_filter) {
      _LogFilter.all => all,
      _LogFilter.insideNow =>
        all.where((r) => r.status == VisitStatus.checkedIn).toList(),
      _LogFilter.checkedOut =>
        all.where((r) => r.status == VisitStatus.checkedOut).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _buildHeader(context),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = math.max(constraints.maxWidth, _minTableWidth);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _buildHeaderRow(),
                      for (final record in rows) _buildDataRow(context, record),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            child: Text(
              'Showing ${rows.length} of ${DashboardSampleData.totalToday} '
              'check-ins today (sample data)',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 22, color: AppColors.brightBlue),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Recent Check-Ins & Real-Time Log',
                      style: AppTextStyles.cardTitle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Continuous chronological terminal transaction log for '
                'American Corner Mombasa.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FilterTabs(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            OutlinedButton.icon(
              onPressed: () => showPreviewNotice(context),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Export Daily Sheet'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _headers.length; i++)
            Expanded(
              flex: _flex[i],
              child: Text(_headers[i], style: AppTextStyles.label),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, CheckInRecord r) {
    final checkedIn = r.status == VisitStatus.checkedIn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _flex[0],
            child: Row(
              children: [
                InitialsAvatar(initials: r.initials, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong),
                      Text(r.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _flex[1],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Pill(label: r.cardNumber, fontSize: 11),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Text(r.checkInTime, style: AppTextStyles.bodyStrong),
          ),
          Expanded(
            flex: _flex[3],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Pill(
                label: r.purpose,
                background: AppColors.infoSoft,
                foreground: AppColors.info,
              ),
            ),
          ),
          Expanded(
            flex: _flex[4],
            child: Align(
              alignment: Alignment.centerLeft,
              child: checkedIn
                  ? const Pill(
                      label: 'Checked In',
                      background: AppColors.successSoft,
                      foreground: AppColors.success,
                      dotColor: AppColors.successDot,
                    )
                  : Pill(label: 'Checked Out (${r.checkedOutAt})'),
            ),
          ),
          Expanded(
            flex: _flex[5],
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => showPreviewNotice(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                    foregroundColor:
                        checkedIn ? AppColors.americanRed : AppColors.brightBlue,
                    side: BorderSide(
                      color: (checkedIn
                              ? AppColors.americanRed
                              : AppColors.brightBlue)
                          .withValues(alpha: 0.45),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: Text(checkedIn ? 'Check Out' : 'Re-Admit'),
                ),
                IconButton(
                  tooltip: 'Print badge',
                  onPressed: () => showPreviewNotice(context),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.badge_outlined,
                      size: 18, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final _LogFilter selected;
  final ValueChanged<_LogFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <(_LogFilter, String)>[
      (_LogFilter.all, 'All (${DashboardSampleData.totalToday})'),
      (_LogFilter.insideNow, 'Inside Now (${DashboardSampleData.insideNow})'),
      (
        _LogFilter.checkedOut,
        'Checked Out (${DashboardSampleData.checkedOutToday})'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd + 2),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (filter, label) in tabs)
            _Tab(
              label: label,
              selected: filter == selected,
              onTap: () => onChanged(filter),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
