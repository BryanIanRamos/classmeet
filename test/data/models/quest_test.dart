import 'package:classmeet/data/models/quest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reset = DateTime(2026, 11, 25);
  final until = DateTime(2026, 11, 29);
  final q = Quest(
    id: 'q1',
    title: 'Daily General Knowledge Quiz',
    kind: QuestKind.daily,
    rewardTalons: 5,
    done: 6,
    total: 7,
    status: QuestStatus.claimed,
    resetsAt: reset,
    availableUntil: until,
    durationMinutes: 1,
  );

  test('builds const with defaults', () {
    const c = Quest(
      id: 'a',
      title: 't',
      kind: QuestKind.survey,
      rewardTalons: 2,
    );
    expect(c.status, QuestStatus.available);
    expect(c.fraction, 0);
    expect(c.remaining, 0);
  });

  test('copyWith() keeps every field', () {
    final c = q.copyWith();
    expect(c.id, 'q1');
    expect(c.title, 'Daily General Knowledge Quiz');
    expect(c.kind, QuestKind.daily);
    expect(c.rewardTalons, 5);
    expect(c.done, 6);
    expect(c.total, 7);
    expect(c.status, QuestStatus.claimed);
    expect(c.resetsAt, reset);
    expect(c.availableUntil, until);
    expect(c.durationMinutes, 1);
  });

  test('copyWith changes only the given field', () {
    final c = q.copyWith(status: QuestStatus.locked);
    expect(c.status, QuestStatus.locked);
    expect(c.done, 6);
    expect(c.kind, QuestKind.daily);
  });

  test('fraction and remaining', () {
    expect(q.fraction, closeTo(6 / 7, 1e-9));
    expect(q.remaining, 1);
    expect(q.copyWith(done: 9).fraction, 1);
    expect(q.copyWith(done: 9).remaining, 0);
    expect(q.copyWith(total: 0).fraction, 0);
  });
}
