import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeScenario.parse', () {
    test('reads the FAKE_SCENARIO values', () {
      expect(FakeScenario.parse('default'), FakeScenario.sample);
      expect(FakeScenario.parse('empty'), FakeScenario.empty);
      expect(FakeScenario.parse('error'), FakeScenario.error);
    });

    test('falls back to sample data for unknown values', () {
      expect(FakeScenario.parse(''), FakeScenario.sample);
      expect(FakeScenario.parse('EMPTY'), FakeScenario.sample);
    });
  });

  group('FakeConfig.answer', () {
    test('returns the data in the sample scenario', () async {
      expect(await FakeConfig.instant.answer('op', () => 7), 7);
      expect(await FakeConfig.instant.answerList('op', () => [1, 2]), [1, 2]);
    });

    test('returns the empty value in the empty scenario', () async {
      const config = FakeConfig(scenario: FakeScenario.empty);
      expect(await config.answerList('op', () => [1, 2]), isEmpty);
      expect(await config.answer('op', () => 7, empty: () => 0), 0);
      // Without an empty value, single objects keep their data.
      expect(await config.answer('op', () => 7), 7);
    });

    test('throws a RepositoryException in the error scenario', () async {
      const config = FakeConfig(scenario: FakeScenario.error);
      await expectLater(
        config.answer('fetchWallet', () => 7),
        throwsA(
          isA<RepositoryException>().having(
            (e) => e.message,
            'message',
            contains('fetchWallet'),
          ),
        ),
      );
      await expectLater(
        config.answerList('op', () => [1]),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('waits for the latency before answering', () async {
      const config = FakeConfig(latency: Duration(milliseconds: 20));
      var done = false;
      final answer = config.answer('op', () => 1).then((v) => done = true);
      await Future<void>.delayed(Duration.zero);
      expect(done, isFalse);
      await answer;
      expect(done, isTrue);
    });
  });

  test('fakeConfigProvider reads the dart-define defaults', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final config = container.read(fakeConfigProvider);
    expect(config.scenario, FakeScenario.sample);
    expect(config.latency, const Duration(milliseconds: 300));
  });
}
