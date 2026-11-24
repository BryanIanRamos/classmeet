import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_notification_repository.dart';
import 'package:classmeet/data/models/app_notification.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  final now = DateTime(2026, 11, 24, 14);
  late FakeNotificationRepository repo;
  setUp(
    () =>
        repo = FakeNotificationRepository(FakeConfig.instant, clock: () => now),
  );

  test('sample items match frame 11, with times from the clock', () async {
    final items = await repo.fetchNotifications();
    expect(items.first.title, 'Quiz due tonight');
    expect(items.first.body, 'ITE13 · Normalization Quiz');
    expect(items.first.at, DateTime(2026, 11, 24, 23, 59));
    final material = items.firstWhere((i) => i.id == 'new-material');
    expect(material.body, 'Prof. Rhea Santos shared a reviewer in ITE13.');
    expect(now.difference(material.at), const Duration(hours: 2));
    final reward = items.firstWhere((i) => i.id == 'streak-reward');
    expect(reward.title, 'You earned 5 Talons!');
    expect(reward.body, 'Your 7-day study streak reward.');
    expect(reward.at.day, 23);
  });

  test('category filter', () async {
    final classes = await repo.fetchNotifications(
      category: NotificationCategory.classes,
    );
    expect(classes, hasLength(2));
    expect(
      classes.every((i) => i.category == NotificationCategory.classes),
      isTrue,
    );
  });

  test('markAllRead persists', () async {
    expect(await repo.unreadCount(), 3);
    await repo.markAllRead();
    expect(await repo.unreadCount(), 0);
    final items = await repo.fetchNotifications();
    expect(items.any((i) => i.isUnread), isFalse);
  });

  test('empty scenario returns nothing', () async {
    final r = FakeNotificationRepository(_empty, clock: () => now);
    expect(await r.fetchNotifications(), isEmpty);
    expect(await r.unreadCount(), 0);
    await r.markAllRead();
  });

  test('error scenario throws', () {
    final r = FakeNotificationRepository(_error, clock: () => now);
    expect(r.fetchNotifications(), throwsA(isA<RepositoryException>()));
    expect(r.markAllRead(), throwsA(isA<RepositoryException>()));
    expect(r.unreadCount(), throwsA(isA<RepositoryException>()));
  });
}
