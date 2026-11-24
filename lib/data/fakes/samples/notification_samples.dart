import '../../models/app_notification.dart';

/// Frame 11, with times relative to [now] so "2hrs ago" stays true.
/// The last two items and their texts are // sample (the design's Yesterday
/// group is empty).
List<AppNotification> notificationSamples(DateTime now) => [
  AppNotification(
    id: 'quiz-due',
    category: NotificationCategory.classes,
    title: 'Quiz due tonight',
    body: 'ITE13 · Normalization Quiz',
    // Shown as "Due at 11:59 PM".
    at: DateTime(now.year, now.month, now.day, 23, 59),
    isUnread: true,
  ),
  AppNotification(
    id: 'new-material',
    category: NotificationCategory.classes,
    title: 'New class material',
    body: 'Prof. Rhea Santos shared a reviewer in ITE13.',
    at: now.subtract(const Duration(hours: 2)),
    isUnread: true,
  ),
  AppNotification(
    id: 'streak-reward',
    category: NotificationCategory.rewards,
    title: 'You earned 5 Talons!',
    body: 'Your 7-day study streak reward.',
    at: now.subtract(const Duration(days: 1)),
    isUnread: true,
  ),
  AppNotification(
    id: 'login-reward',
    category: NotificationCategory.rewards,
    title: 'Daily login reward',
    body: 'You claimed day 2 of your login rewards.',
    at: now.subtract(const Duration(days: 1, hours: 3)),
  ),
  AppNotification(
    id: 'welcome',
    category: NotificationCategory.system,
    title: 'Welcome to ClassMeet',
    body: 'Your account is ready. Join a class to get started.',
    at: now.subtract(const Duration(days: 1, hours: 6)),
  ),
];
