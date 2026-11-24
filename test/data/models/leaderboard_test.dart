import 'package:classmeet/data/models/leaderboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LeaderboardEntry', () {
    const e = LeaderboardEntry(
      rank: 1,
      name: 'Joshua Rosales',
      duration: Duration(minutes: 4, seconds: 12),
      percent: 100,
      correct: 20,
      total: 20,
    );
    expect(e.visibility, RankingVisibility.displayName);
    expect(e.isYou, isFalse);
    final c = e.copyWith();
    expect(
      [c.rank, c.name, c.percent, c.correct, c.total],
      [1, 'Joshua Rosales', 100, 20, 20],
    );
    expect(c.duration, const Duration(minutes: 4, seconds: 12));
    expect(c.visibility, RankingVisibility.displayName);
    expect(c.isYou, isFalse);
    final d = e.copyWith(isYou: true);
    expect(d.isYou, isTrue);
    expect(d.rank, 1);
  });

  test('enum labels', () {
    expect(RankingVisibility.values.map((e) => e.label), [
      'Display name',
      'Nickname',
      'Anonymous',
    ]);
    expect(LeaderboardScope.values.map((e) => e.label), [
      'Friend',
      'Class',
      'Link',
    ]);
  });
}
