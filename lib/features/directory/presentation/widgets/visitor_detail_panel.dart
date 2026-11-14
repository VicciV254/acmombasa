import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/domain/app_exception.dart';
import '../../../../core/domain/directory_models.dart';
import '../../../../core/domain/models.dart';
import '../../../../core/providers.dart';
import '../../../../core/services/badge_printer.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/text_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/pill.dart';
import '../../../dashboard/presentation/dialogs/visitor_history_dialog.dart';
import '../../application/directory_providers.dart';
import '../dialogs/edit_visitor_dialog.dart';

class VisitorDetailPanel extends ConsumerWidget {
  const VisitorDetailPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedVisitorIdProvider);
    if (id == null) {
      return const AppCard(
        child: Center(
          child: Text('Select a visitor to see their profile.',
              style: AppTextStyles.body),
        ),
      );
    }
    final profile = ref.watch(visitorProfileProvider(id));
    return AppCard(
      padding: EdgeInsets.zero,
      child: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load profile.\n$e')),
        data: (p) => p == null
            ? const Center(child: Text('Visitor not found.'))
            : _Profile(data: p),
      ),
    );
  }
}

class _Profile extends ConsumerStatefulWidget {
  const _Profile({required this.data});

  final VisitorProfileData data;

  @override
  ConsumerState<_Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<_Profile> {
  bool _busy = false;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> _checkOut() => _run(() async {
        await ref
            .read(visitRepositoryProvider)
            .checkOut(widget.data.openVisit!.id);
        _toast('${widget.data.visitor.fullName} checked out.');
      });

  Future<void> _checkIn() async {
    final staff = ref.read(sessionProvider);
    if (staff == null) return;
    final options = await ref.read(programRepositoryProvider).purposeOptions();
    if (!mounted) return;
    final choice = await showDialog<PurposeOption>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Purpose of Visit'),
        children: [
          for (final o in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(o),
              child: Text(o.label),
            ),
        ],
      ),
    );
    if (choice == null) return;
    await _run(() async {
      await ref.read(visitRepositoryProvider).checkIn(
            visitor: widget.data.visitor,
            staffId: staff.id,
            purpose: choice.label,
            programId: choice.programId,
          );
      _toast('${widget.data.visitor.fullName} checked in.');
    });
  }

  Future<void> _edit() async {
    final saved = await showEditVisitorDialog(context, widget.data.visitor);
    if (saved != null && mounted) _toast('Profile updated.');
  }

  Future<void> _badge() => _run(() => BadgePrinter.print(
        visitor: widget.data.visitor,
        visit: widget.data.openVisit,
      ));

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final v = d.visitor;
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            InitialsAvatar(initials: initialsOf(v.fullName), size: 56),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.fullName, style: AppTextStyles.cardTitle),
                  Text('${v.memberId} • Member since ${DateFormatter.shortDate(v.registeredAt)}',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  Pill(
                    label: d.isInside ? 'Inside Now' : 'Not inside',
                    background:
                        d.isInside ? AppColors.successSoft : AppColors.neutralSoft,
                    foreground:
                        d.isInside ? AppColors.success : AppColors.textSecondary,
                    dotColor: d.isInside ? AppColors.successDot : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _busy ? null : _edit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit Profile'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _badge,
              icon: const Icon(Icons.badge_outlined, size: 16),
              label: const Text('Print Badge'),
            ),
            FilledButton.icon(
              onPressed: _busy ? null : (d.isInside ? _checkOut : _checkIn),
              style: FilledButton.styleFrom(
                backgroundColor: d.isInside ? AppColors.americanRed : AppColors.navy,
              ),
              icon: Icon(d.isInside ? Icons.logout : Icons.login, size: 16),
              label: Text(d.isInside ? 'Check-Out' : 'Check In'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('VISIT ANALYTICS', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Row(
          children: [
            _tile('Total Visits', groupThousands(d.totalVisits)),
            _tile('Monthly Avg', d.monthlyAverage.toStringAsFixed(1)),
            _tile('Avg. Stay',
                d.avgStayMinutes == null ? '—' : formatMinutes(d.avgStayMinutes!)),
            _tile('Favorite Day',
                d.favoriteWeekday == null ? '—' : weekdayName(d.favoriteWeekday!)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text('DEMOGRAPHIC & CONTACT', style: AppTextStyles.label),
        const SizedBox(height: 8),
        _kv('Phone', PhoneUtils.format(v.phone)),
        _kv('Email', v.email ?? 'Not recorded'),
        _kv('Category', v.category),
        _kv('Age Bracket', 'Not recorded'),
        _kv('Residence', 'Not recorded'),
        _kv('Occupation', 'Not recorded'),
        const SizedBox(height: AppSpacing.lg),
        const Text('PREFERRED PROGRAMS', style: AppTextStyles.label),
        const SizedBox(height: 8),
        d.topPurposes.isEmpty
            ? const Text('No visits yet.', style: AppTextStyles.caption)
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in d.topPurposes)
                    Pill(
                      label: p,
                      background: AppColors.infoSoft,
                      foreground: AppColors.info,
                    ),
                ],
              ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Data recorded with the visitor\'s consent at registration.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            const Text('PREVIOUS VISIT LOGS', style: AppTextStyles.label),
            const Spacer(),
            if (d.totalVisits > d.recent.length)
              TextButton(
                onPressed: () => showVisitorHistoryDialog(context, v),
                child: Text('View All ${d.totalVisits} Logs'),
              ),
          ],
        ),
        if (d.recent.isEmpty)
          const Text('No visits recorded yet.', style: AppTextStyles.caption)
        else
          for (final r in d.recent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(dayLabel(r.visit.checkInAt, now),
                        style: AppTextStyles.bodyStrong),
                  ),
                  Expanded(
                    child: Text(
                      '${r.visit.purpose}${r.location == null ? '' : ' • ${r.location}'}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body,
                    ),
                  ),
                  Text(
                    r.visit.checkOutAt == null
                        ? 'Inside'
                        : formatDuration(
                            r.visit.checkOutAt!.difference(r.visit.checkInAt)),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _tile(String label, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceTinted,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle),
            ],
          ),
        ),
      );

  Widget _kv(String k, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(k, style: AppTextStyles.caption)),
            Expanded(child: Text(value, style: AppTextStyles.bodyStrong)),
          ],
        ),
      );
}
