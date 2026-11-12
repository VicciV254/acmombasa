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

/// "Find a Visitor" lookup plus the selected visitor's check-in panel.
/// Controls hold local UI state only; actions show a preview notice.
class FindVisitorCard extends StatefulWidget {
  const FindVisitorCard({super.key});

  @override
  State<FindVisitorCard> createState() => _FindVisitorCardState();
}

class _FindVisitorCardState extends State<FindVisitorCard> {
  late final TextEditingController _search;
  String _purpose = DashboardSampleData.visitPurposes.first;
  bool _assignWorkstation = true;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: 'Amina Hassan (0722 849 102)');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const visitor = DashboardSampleData.visitor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.person_search,
                  size: 22, color: AppColors.brightBlue),
              const SizedBox(width: 8),
              const Text('Find a Visitor', style: AppTextStyles.cardTitle),
              const Spacer(),
              const Flexible(
                child: Pill(label: 'RFID/Scanner Armed', icon: Icons.sensors),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Quick lookup by phone, name, or assigned ID to record '
            'attendance with 1-click.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSearchRow(context),
          const SizedBox(height: AppSpacing.md),
          _buildVisitorPanel(context, visitor),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: c),
        );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _search,
            style: AppTextStyles.bodyStrong,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search by name, phone or ID',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: border(AppColors.borderStrong),
              enabledBorder: border(AppColors.borderStrong),
              focusedBorder: border(AppColors.brightBlue),
            ),
            onSubmitted: (_) => showPreviewNotice(context),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () => showPreviewNotice(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.navy,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text('SEARCH'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => showPreviewNotice(context),
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: const Text('New'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.americanRed,
            side: BorderSide(
                color: AppColors.americanRed.withValues(alpha: 0.45)),
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitorPanel(BuildContext context, VisitorProfile visitor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTinted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    const Pill(
                      label: 'Active Member • Verified Profile',
                      background: AppColors.successSoft,
                      foreground: AppColors.success,
                      icon: Icons.verified_outlined,
                    ),
                    Pill(label: visitor.memberId),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  visitor.lastVisited,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(initials: visitor.initials, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            visitor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified,
                            size: 16, color: AppColors.brightBlue),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(visitor.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption),
                    Text(
                      visitor.phone,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('MEMBER SINCE', style: AppTextStyles.label),
                  Text(visitor.memberSince, style: AppTextStyles.bodyStrong),
                  const SizedBox(height: 8),
                  const Text('CUMULATIVE ATTENDANCE',
                      style: AppTextStyles.label),
                  Text(visitor.totalVisits, style: AppTextStyles.bodyStrong),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPurposeField(context)),
              const SizedBox(width: 14),
              Expanded(child: _buildResources()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionRow(context),
          const SizedBox(height: 12),
          _buildSuccessBanner(),
        ],
      ),
    );
  }

  Widget _buildPurposeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Purpose of Visit', style: AppTextStyles.bodyStrong),
            ),
            InkWell(
              onTap: () => showPreviewNotice(context),
              child: Text(
                'Privacy Activity',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brightBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _purpose,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: AppTextStyles.bodyStrong,
              items: [
                for (final p in DashboardSampleData.visitPurposes)
                  DropdownMenuItem(
                    value: p,
                    child: Text(p, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _purpose = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Terminal Resources', style: AppTextStyles.bodyStrong),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Row(
            children: [
              Checkbox(
                value: _assignWorkstation,
                visualDensity: VisualDensity.compact,
                onChanged: (v) =>
                    setState(() => _assignWorkstation = v ?? false),
              ),
              const Expanded(
                child: Text(
                  'Assign Public Workstation: PC-04',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => showPreviewNotice(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brightBlue,
              minimumSize: const Size(0, 48),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.how_to_reg_outlined, size: 20),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text('CHECK IN VISITOR', overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('F2', style: TextStyle(fontSize: 10.5)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () => showPreviewNotice(context),
          icon: const Icon(Icons.print_outlined, size: 18),
          label: const Text('Print Badge'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
        ),
      ],
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: AppColors.success),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Amina checked in today at 10:42 AM',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' • Assigned to PC-04 (English Club)'),
                ],
              ),
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
