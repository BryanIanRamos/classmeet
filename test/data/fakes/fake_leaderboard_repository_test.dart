import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_leaderboard_repository.dart';
import 'package:classmeet/data/models/leaderboard.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  test('sample rows match 132', () async {
    final rows = await const FakeLeaderboardRepository(
      FakeConfig.instant,
    ).fetchLeaderboard('intro-computing');
    expect(rows.map((r) => r.name), [
      'Joshua Rosales',
      'Big Mac',
      'Anonymous Hoot',
      'Owl_4821',
    ]);
    expect(rows.map((r) => r.rank), [1, 2, 3, 4]);
    expect(rows[0].duration, const Duration(minutes: 4, seconds: 12));
    expect((rows[0].percent, rows[0].correct, rows[0].total), (100, 20, 20));
    expect(rows[1].visibility, RankingVisibility.nickname);
    expect(rows[1].duration, const Duration(minutes: 5, seconds: 3));
    expect(rows[2].visibility, RankingVisibility.anonymous);
    expect(rows[3].isYou, isTrue);
    expect((rows[3].percent, rows[3].correct), (80, 16));
    expect(rows.where((r) => r.isYou), hasLength(1));
  });

  test('every scope returns the same list', () async {
    const repo = FakeLeaderboardRepository(FakeConfig.instant);
    final byClass = await repo.fetchLeaderboard('intro-computing');
    for (final scope in LeaderboardScope.values) {
      final rows = await repo.fetchLeaderboard('intro-computing', scope: scope);
      expect(rows.map((r) => r.name), byClass.map((r) => r.name));
    }
  });

  test('empty scenario returns an empty list', () async {
    expect(
      await const FakeLeaderboardRepository(_empty).fetchLeaderboard('x'),
      isEmpty,
    );
  });

  test('error scenario throws RepositoryException', () async {
    await expectLater(
      const FakeLeaderboardRepository(_error).fetchLeaderboard('x'),
      throwsA(isA<RepositoryException>()),
    );
  });
}
