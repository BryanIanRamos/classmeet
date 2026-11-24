import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_wallet_repository.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeWalletRepository repo;
  setUp(() => repo = FakeWalletRepository(FakeConfig.instant));

  test('sample wallet, reward progress and streak match the design', () async {
    final w = await repo.fetchWallet();
    expect(w.talons, 24);
    expect(w.studyPoints, 300);
    final p = await repo.fetchRewardProgress();
    expect((p.nextRewardTalons, p.done, p.total), (10, 171, 300));
    final s = await repo.fetchStreak();
    expect((s.days, s.freezesLeft), (6, 1));
  });

  test('spendTalons persists', () async {
    final after = await repo.spendTalons(1, reason: 'explain');
    expect(after.talons, 23);
    expect((await repo.fetchWallet()).talons, 23);
  });

  test('spendTalons beyond the balance fails and keeps the balance', () async {
    await expectLater(
      repo.spendTalons(25, reason: 'x'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      repo.spendTalons(0, reason: 'x'),
      throwsA(isA<RepositoryException>()),
    );
    expect((await repo.fetchWallet()).talons, 24);
  });

  test('earn adds to every balance and persists', () async {
    final before = await repo.fetchWallet();
    await repo.earn(talons: 5, studyPoints: 10, xp: 2);
    final after = await repo.fetchWallet();
    expect(after.talons, 29);
    expect(after.studyPoints, 310);
    expect(after.xp, before.xp + 2);
    expect(repo.earn(talons: -1), throwsA(isA<RepositoryException>()));
  });

  test('empty scenario still serves the wallet', () async {
    final r = FakeWalletRepository(_empty);
    expect((await r.fetchWallet()).talons, 24);
  });

  test('error scenario throws', () {
    final r = FakeWalletRepository(_error);
    expect(r.fetchWallet(), throwsA(isA<RepositoryException>()));
    expect(r.fetchRewardProgress(), throwsA(isA<RepositoryException>()));
    expect(r.fetchStreak(), throwsA(isA<RepositoryException>()));
    expect(r.spendTalons(1, reason: 'x'), throwsA(isA<RepositoryException>()));
    expect(r.earn(talons: 1), throwsA(isA<RepositoryException>()));
  });
}
