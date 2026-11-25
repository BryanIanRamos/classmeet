import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/providers.dart';

/// Which day group a notification sits in (frame 11).
enum NotificationGroup {
  today('Today'),
  yesterday('Yesterday'),

  /// Provisional label: the design only shows Today and Yesterday.
  earlier('Earlier');

  const NotificationGroup(this.label);

  final String label;
}

/// The group of [at] relative to [now], by calendar day. Anything later than
/// today (a future due time) counts as today.
NotificationGroup groupFor(DateTime at, DateTime now) {
  final days = _dayOnly(now).difference(_dayOnly(at)).inDays;
  if (days <= 0) return NotificationGroup.today;
  if (days == 1) return NotificationGroup.yesterday;
  return NotificationGroup.earlier;
}

/// The time line under a notification: "Due at 11:59 PM" for a time still
/// ahead, "2hrs ago" for earlier today, "Yesterday", then "N days ago".
String timeLabel(DateTime at, DateTime now) {
  if (at.isAfter(now)) return 'Due at ${_clock12(at)}';
  final days = _dayOnly(now).difference(_dayOnly(at)).inDays;
  if (days == 0) {
    final diff = now.difference(at);
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      return h == 1 ? '1hr ago' : '${h}hrs ago';
    }
    final m = diff.inMinutes;
    return m < 1 ? 'Just now' : '${m}min ago';
  }
  if (days == 1) return 'Yesterday';
  return '$days days ago';
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _clock12(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// The notification list and its filter (11). The filter is [category]
/// (null = All); changing it refetches.
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  NotificationCategory? _category;
  int _request = 0;

  /// The selected filter chip; null is "All". Read it after watching the
  /// provider, so it stays right while the list is loading or failed.
  NotificationCategory? get category => _category;

  @override
  Future<List<AppNotification>> build() => _fetch();

  Future<List<AppNotification>> _fetch() => ref
      .read(notificationRepositoryProvider)
      .fetchNotifications(category: _category);

  /// Switches the filter and refetches.
  Future<void> selectCategory(NotificationCategory? category) async {
    if (category == _category && state.hasValue) return;
    _category = category;
    await reload();
  }

  /// Reloads the current filter (the error state's retry).
  Future<void> reload() async {
    final request = ++_request;
    state = const AsyncLoading<List<AppNotification>>();
    final next = await AsyncValue.guard(_fetch);
    // Drop an answer that arrives after a newer request or after the screen
    // closed (the provider is auto-disposed).
    if (ref.mounted && request == _request) state = next;
  }

  /// Marks everything read; the unread dots go away.
  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    if (!ref.mounted) return;
    final items = state.value;
    if (items == null) return;
    state = AsyncData([
      for (final item in items) item.copyWith(isUnread: false),
    ]);
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      List<AppNotification>
    >(NotificationsController.new);
