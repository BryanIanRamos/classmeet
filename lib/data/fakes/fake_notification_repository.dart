import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';
import 'fake_config.dart';
import 'samples/notification_samples.dart';

/// In-memory [NotificationRepository]; "2hrs ago" and friends are relative
/// to the clock. [markAllRead] clears every unread flag.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository(this._config, {DateTime Function()? clock})
    : _items = _config.isEmpty
          ? []
          : notificationSamples((clock ?? DateTime.now)());

  final FakeConfig _config;
  List<AppNotification> _items;

  @override
  Future<List<AppNotification>> fetchNotifications({
    NotificationCategory? category,
  }) => _config.answerList(
    'fetchNotifications',
    () => [
      for (final item in _items)
        if (category == null || item.category == category) item,
    ],
  );

  @override
  Future<void> markAllRead() => _config.answer('markAllRead', () {
    _items = [for (final item in _items) item.copyWith(isUnread: false)];
  });

  @override
  Future<int> unreadCount() => _config.answer(
    'unreadCount',
    () => _items.where((i) => i.isUnread).length,
  );
}
