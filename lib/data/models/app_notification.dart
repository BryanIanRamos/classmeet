/// Notification filter chips (11), after "All".
enum NotificationCategory {
  classes('Classes'),
  rewards('Rewards'),
  system('System');

  const NotificationCategory(this.label);

  final String label;
}

/// A notification row (11).
final class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.at,
    this.isUnread = false,
  });

  final String id;
  final NotificationCategory category;
  final String title;
  final String body;

  /// When it happened; the UI formats "2hrs ago" / "Yesterday".
  final DateTime at;
  final bool isUnread;

  AppNotification copyWith({
    String? id,
    NotificationCategory? category,
    String? title,
    String? body,
    DateTime? at,
    bool? isUnread,
  }) {
    return AppNotification(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      body: body ?? this.body,
      at: at ?? this.at,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
