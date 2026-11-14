import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/app_exception.dart';
import '../../../../core/domain/history_models.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/badge_printer.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pill.dart';
import '../../application/history_providers.dart';

class SessionInspector extends ConsumerStatefulWidget {
  const SessionInspector({super.key, required this.report});

  final HistoryReport report;

  @override
  ConsumerState<SessionInspector> createState() => _SessionInspectorState();
}

class _SessionInspectorState extends ConsumerState<SessionInspector> {
  bool _busy = false;

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = ref.watch(selectedHistoryEntryIdProvider);
    final entry = widget.report.entries
        .where((e) => e.visit.id == id)
        .cast<HistoryEntry?>()
        .firstOrNull;
    final now = DateTime.now();

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('SESSION INSPECTOR', style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.md),
          if (entry == null)
            const Text('Select a row in the terminal log to inspect it.',
                style: AppTextStyles.body)
          else ...[
            Text(entry.visitor.fullName, style: AppTextStyles.cardTitle),
            Text('${entry.visitor.memberId} • ${entry.visitor.category}',
                style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Pill(
              label: entry.isOpen ? 'Inside Now' : 'Completed',
              background:
                  entry.isOpen ? AppColors.successSoft : AppColors.neutralSoft,
              foreground:
                  entry.isOpen ? AppColors.success : AppColors.textSecondary,
              dotColor: entry.isOpen ? AppColors.successDot : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _kv('Date', DateFormatter.longDate(entry.visit.checkInAt)),
            _kv('Check-in', DateFormatter.time12(entry.visit.checkInAt)),
            _kv('Check-out',
                entry.isOpen ? 'Still inside' : DateFormatter.time12(entry.visit.checkOutAt!)),
            _kv(
              'Duration',
              formatDuration(
                  entry.duration ?? now.difference(entry.visit.checkInAt)),
            ),
            _kv('Purpose', entry.visit.purpose),
            _kv('Room / workstation', entry.space),
            _kv('Checked in by', entry.staffName),
            _kv('Record ID', entry.visit.id),
            const SizedBox(height: AppSpacing.md),
            const Text('LOG NOTE', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(_note(entry, now), style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => BadgePrinter.print(
                          visitor: entry.visitor,
                          visit: entry.visit,
                        )),
                icon: const Icon(Icons.badge_outlined, size: 16),
                label: const Text('Re-print Badge'),
              ),
              if (entry.isOpen)
                FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                            await ref
                                .read(visitRepositoryProvider)
                                .checkOut(entry.visit.id);
                            _toast('${entry.visitor.fullName} checked out.');
                          }),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.americanRed),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Check Out Now'),
                )
              else
                FilledButton.icon(
                  onPressed: _busy ? null : () => _readmit(entry),
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.navy),
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Re-Admit'),
                ),
            ]),
          ],
          const SizedBox(height: AppSpacing.lg),
          const Text('LOG DISTRIBUTION BY PILLAR', style: AppTextStyles.label),
          const SizedBox(height: 8),
          if (widget.report.distribution.isEmpty)
            const Text('No visits in range.', style: AppTextStyles.caption)
          else
            for (final s in widget.report.distribution)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(s.label,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyStrong)),
                      Text('${s.count} • ${(s.fraction * 100).round()}%',
                          style: AppTextStyles.caption),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.fraction,
                        minHeight: 6,
                        backgroundColor: AppColors.neutralSoft,
                        color: AppColors.brightBlue,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _readmit(HistoryEntry entry) async {
    final staff = ref.read(sessionProvider);
    if (staff == null) return;
    await _run(() async {
      await ref
          .read(visitRepositoryProvider)
          .readmit(previous: entry.visit, staffId: staff.id);
      _toast('${entry.visitor.fullName} re-admitted.');
    });
  }

  String _note(HistoryEntry e, DateTime now) {
    final when = '${dayLabel(e.visit.checkInAt, now)} at '
        '${DateFormatter.time12(e.visit.checkInAt)}';
    final where = e.space;
    if (e.isOpen) {
      return '${e.visitor.fullName} checked in for "${e.visit.purpose}" on '
          '$when ($where) and is still inside.';
    }
    return '${e.visitor.fullName} attended "${e.visit.purpose}" on $when '
        '($where) for ${formatDuration(e.duration!)}.';
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(k, style: AppTextStyles.caption)),
            Expanded(
                child: Text(v,
                    style: AppTextStyles.bodyStrong,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2)),
          ],
        ),
      );
}
