import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_profile_repository.dart';
import 'package:classmeet/data/models/leaderboard.dart';
import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeProfileRepository repo;
  setUp(() => repo = FakeProfileRepository(FakeConfig.instant));

  test('fetchProfile returns the design student', () async {
    final p = await repo.fetchProfile();
    expect(p.fullName, 'Bryan Ramos');
    expect(p.nickname, 'Owl_4821');
    expect(p.programLabel, 'BSIT 2A');
    expect(p.schoolShort, 'CSU');
    expect(p.yearLevel, YearLevel.second);
    expect(p.email, 'student@example.com');
  });

  test('onboarding prefs persist', () async {
    expect((await repo.fetchOnboardingPrefs()).schoolId, 'csu');
    await repo.saveOnboardingPrefs(
      const OnboardingPrefs(yearLevel: YearLevel.third, programId: 'csu-bsit'),
    );
    final prefs = await repo.fetchOnboardingPrefs();
    expect(prefs.yearLevel, YearLevel.third);
    expect(prefs.programId, 'csu-bsit');
  });

  test('ranking visibility persists', () async {
    expect(await repo.fetchRankingVisibility(), RankingVisibility.displayName);
    await repo.saveRankingVisibility(RankingVisibility.anonymous);
    expect(await repo.fetchRankingVisibility(), RankingVisibility.anonymous);
  });

  test('empty scenario still serves the profile', () async {
    final r = FakeProfileRepository(_empty);
    expect((await r.fetchProfile()).nickname, 'Owl_4821');
  });

  test('error scenario throws', () {
    final r = FakeProfileRepository(_error);
    expect(r.fetchProfile(), throwsA(isA<RepositoryException>()));
    expect(r.fetchOnboardingPrefs(), throwsA(isA<RepositoryException>()));
    expect(
      r.saveOnboardingPrefs(const OnboardingPrefs()),
      throwsA(isA<RepositoryException>()),
    );
    expect(r.fetchRankingVisibility(), throwsA(isA<RepositoryException>()));
    expect(
      r.saveRankingVisibility(RankingVisibility.nickname),
      throwsA(isA<RepositoryException>()),
    );
  });
}
