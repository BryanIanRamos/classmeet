import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/navigation/app_navbar_item.dart';
import '../../../../core/widgets/selection/app_chip.dart';
import '../../../../data/models/app_notification.dart';

/// The chip row under the title (frame 11): All / Classes / Rewards / System
/// and the filter icon. The chips scroll sideways when they do not fit (360).
///
/// The filter icon has no designed target, so it does nothing (GAP).
class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// The selected category; null is "All".
  final NotificationCategory? selected;
  final ValueChanged<NotificationCategory?> onSelected;

  /// Gap between chips (Figma 8 via the row padding).
  static const chipGap = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                AppChip.choice(
                  label: 'All',
                  style: AppChipStyle.tonal,
                  selected: selected == null,
                  onSelected: (_) => onSelected(null),
                ),
                for (final category in NotificationCategory.values) ...[
                  const SizedBox(width: chipGap),
                  AppChip.choice(
                    label: category.label,
                    style: AppChipStyle.tonal,
                    selected: selected == category,
                    onSelected: (_) => onSelected(category),
                  ),
                ],
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: AppSpacing.sm),
          child: AppNavbarItem.icon(
            icon: AppIcons.listFilter,
            semanticLabel: 'Filter',
            onTap: null,
          ),
        ),
      ],
    );
  }
}
