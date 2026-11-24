import 'package:classmeet/data/models/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime(2026, 11, 24, 10);
  final n = AppNotification(
    id: 'n1',
    category: NotificationCategory.rewards,
    title: 'You earned 5 Talons!',
    body: 'Your 7-day study streak reward',
    at: at,
    isUnread: true,
  );

  test('defaults to read', () {
    final r = AppNotification(
      id: 'x',
      category: NotificationCategory.system,
      title: 't',
      body: 'b',
      at: at,
    );
    expect(r.isUnread, isFalse);
  });

  test('copyWith() keeps every field', () {
    final c = n.copyWith();
    expect(c.id, 'n1');
    expect(c.category, NotificationCategory.rewards);
    expect(c.title, 'You earned 5 Talons!');
    expect(c.body, 'Your 7-day study streak reward');
    expect(c.at, at);
    expect(c.isUnread, isTrue);
  });

  test('copyWith changes only the given field', () {
    final c = n.copyWith(isUnread: false);
    expect(c.isUnread, isFalse);
    expect(c.title, 'You earned 5 Talons!');
    expect(c.category, NotificationCategory.rewards);
  });

  test('category labels', () {
    expect(NotificationCategory.values.map((e) => e.label), [
      'Classes',
      'Rewards',
      'System',
    ]);
  });
}
