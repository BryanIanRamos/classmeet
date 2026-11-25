import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/clock.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/display/section_header.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../../../data/models/app_notification.dart';
import '../../application/notifications_controller.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_tile.dart';

/// Notifications (frame 11): a back bar, the All / Classes / Rewards / System
/// chips, and the list grouped by day with "Mark all as read".
///
/// Rows do not navigate (no designed target). Empty and error copy is
/// provisional.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  /// Gap between rows, and between a group and the next.
  static const rowGap = AppSpacing.xs;
  static const groupGap = AppSpacing.md;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final now = ref.watch(clockProvider)();

    final Widget body;
    if (state.hasError && !state.isLoading) {
      body = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ErrorState(onRetry: controller.reload),
        ),
      );
    } else if (state.hasValue && !state.isLoading) {
      final items = state.requireValue;
      body = items.isEmpty
          ? const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.md),
                child: EmptyState(
                  title: 'No notifications yet',
                  message: "You're all caught up.",
                ),
              ),
            )
          : _NotificationList(
              items: items,
              now: now,
              onMarkAllRead: controller.markAllRead,
            );
    } else {
      body = const Center(child: AppLoader());
    }

    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppNavbarTop(
                  title: 'Notifications',
                  onBack: () => Navigator.maybePop(context),
                ),
                NotificationFilterBar(
                  selected: controller.category,
                  onSelected: controller.selectCategory,
                ),
              ],
            ),
          ),
          Expanded(child: ScreenBackground(child: body)),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.items,
    required this.now,
    required this.onMarkAllRead,
  });

  final List<AppNotification> items;
  final DateTime now;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final hasUnread = items.any((n) => n.isUnread);
    final groups = <NotificationGroup, List<AppNotification>>{};
    for (final item in items) {
      groups.putIfAbsent(groupFor(item.at, now), () => []).add(item);
    }
    final ordered = [
      for (final g in NotificationGroup.values)
        if (groups[g] case final list?) (g, list),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (var i = 0; i < ordered.length; i++) ...[
          if (i > 0) const SizedBox(height: NotificationsScreen.groupGap),
          // "Mark all as read" sits on the first group's header.
          SectionHeader(
            title: ordered[i].$1.label,
            actionLabel: i == 0 && hasUnread ? 'Mark all as read' : null,
            onActionTap: i == 0 && hasUnread ? onMarkAllRead : null,
          ),
          for (final item in ordered[i].$2) ...[
            const SizedBox(height: NotificationsScreen.rowGap),
            NotificationTile(
              notification: item,
              timeText: timeLabel(item.at, now),
            ),
          ],
        ],
      ],
    );
  }
}
