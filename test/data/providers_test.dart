import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer containerWith(FakeConfig config) {
  final container = ProviderContainer(
    overrides: [fakeConfigProvider.overrideWithValue(config)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('bound repositories serve the sample data', () async {
    final c = containerWith(FakeConfig.instant);
    expect((await c.read(walletRepositoryProvider).fetchWallet()).talons, 24);
    expect(await c.read(classRepositoryProvider).fetchClasses(), isNotEmpty);
    expect(
      await c.read(notificationRepositoryProvider).fetchNotifications(),
      isNotEmpty,
    );
    expect(await c.read(catalogRepositoryProvider).fetchSchools(), isNotEmpty);
    expect(await c.read(questRepositoryProvider).fetchQuests(), isNotEmpty);
    expect(
      (await c.read(profileRepositoryProvider).fetchProfile()).nickname,
      'Owl_4821',
    );
    expect(await c.read(authRepositoryProvider).currentUser(), isNull);
    expect(
      await c.read(searchRepositoryProvider).fetchRecentSearches(),
      isNotEmpty,
    );
  });

  test('one repository instance per container, so writes persist', () async {
    final c = containerWith(FakeConfig.instant);
    expect(
      identical(
        c.read(walletRepositoryProvider),
        c.read(walletRepositoryProvider),
      ),
      isTrue,
    );
    await c.read(walletRepositoryProvider).spendTalons(1, reason: 'test');
    expect((await c.read(walletRepositoryProvider).fetchWallet()).talons, 23);
  });

  test(
    'study repositories serve week-1, and AI spends shared talons',
    () async {
      final c = containerWith(FakeConfig.instant);
      expect(
        await c.read(readerRepositoryProvider).fetchSections('week-1'),
        isNotEmpty,
      );
      expect(
        await c.read(materialRepositoryProvider).fetchRecent(),
        isNotEmpty,
      );
      expect(
        await c.read(downloadRepositoryProvider).fetchPacks(),
        hasLength(3),
      );

      await c
          .read(aiRepositoryProvider)
          .explain(
            materialId: 'week-1',
            text: 'A computer follows the input–process–output cycle.',
          );
      expect((await c.read(walletRepositoryProvider).fetchWallet()).talons, 23);
    },
  );

  test('the empty and error scenarios reach the fakes', () async {
    final empty = containerWith(
      const FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero),
    );
    expect(await empty.read(classRepositoryProvider).fetchClasses(), isEmpty);

    final error = containerWith(
      const FakeConfig(scenario: FakeScenario.error, latency: Duration.zero),
    );
    await expectLater(
      error.read(walletRepositoryProvider).fetchWallet(),
      throwsA(isA<RepositoryException>()),
    );
  });
}
