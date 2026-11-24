import '../models/app_notification.dart';

/// The notification list (11).
abstract interface class NotificationRepository {
  /// Newest first; [category] null means All.
  Future<List<AppNotification>> fetchNotifications({
    NotificationCategory? category,
  });

  Future<void> markAllRead();

  /// For the bell badge on Home (8).
  Future<int> unreadCount();
}
