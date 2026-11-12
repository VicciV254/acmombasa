import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/nav_destination.dart';

class SidebarNavItem extends StatelessWidget {
  const SidebarNavItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.sidebarText;

    final content = compact
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Icon(destination.icon, size: 20, color: color)),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(destination.icon, size: 19, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: compact ? destination.label : '',
        child: Material(
          color: selected ? AppColors.brightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            hoverColor: Colors.white.withValues(alpha: 0.06),
            onTap: onTap,
            child: content,
          ),
        ),
      ),
    );
  }
}
