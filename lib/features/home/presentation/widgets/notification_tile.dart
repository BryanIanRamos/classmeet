import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/app_notification.dart';

/// One notification row (frame 11): an icon in a round slot, the title, the
/// body and the time, with a Sage-500 dot while unread.
///
/// Unread rows are filled Grey-100 (the "Today" cards); read rows are white
/// with a Grey-200 outline and a Grey-100 icon circle (the "Yesterday" cards).
/// The design only shows that split by group, so keying it on [unread] is an
/// assumption. The row does not navigate (no designed target).
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.timeText,
  });

  final AppNotification notification;

  /// "2hrs ago", "Yesterday", "Due at 11:59 PM".
  final String timeText;

  /// Round icon slot.
  static const iconSlot = 40.0;
  static const iconSize = 24.0;
  static const dotSize = 8.0;

  /// Gap between the icon and the text, and before the dot.
  static const gap = 10.0;

  /// The icon for a notification: no icon in the model, so it comes from the
  /// category (quiz reminders get the clipboard).
  static IconData iconFor(AppNotification n) => switch (n.category) {
    NotificationCategory.classes =>
      n.title.toLowerCase().contains('quiz')
          ? AppIcons.clipboardCheck
          : AppIcons.bookOpen,
    NotificationCategory.rewards => AppIcons.coins,
    NotificationCategory.system => AppIcons.bell,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unread = notification.isUnread;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: unread ? AppColors.grey100 : colors.surfaceWhite,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
        border: unread ? null : Border.all(color: AppColors.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSlot,
            height: iconSlot,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconFor(notification),
              size: iconSize,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTypography.b2.copyWith(color: colors.textPrimary),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Text(
                    notification.body,
                    style: AppTypography.c1.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  timeText,
                  style: AppTypography.c3.copyWith(color: colors.textGrey),
                ),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: gap),
            Semantics(
              label: 'Unread',
              child: Container(
                key: const ValueKey('unread-dot'),
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: AppColors.sage500,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
