import '../../core/env.dart';
import '../repositories/repository_exception.dart';

/// Which sample data the fake repositories serve (`FAKE_SCENARIO`).
enum FakeScenario {
  /// The design's sample data (`FAKE_SCENARIO=default`).
  sample,

  /// Every list comes back empty, for the empty states (GAP-21).
  empty,

  /// Every call fails with a [RepositoryException], for the error states.
  error;

  /// Parses the `FAKE_SCENARIO` value; unknown values fall back to [sample].
  static FakeScenario parse(String value) => switch (value) {
    'empty' => empty,
    'error' => error,
    _ => sample,
  };
}

/// Shared behaviour of all fake repositories: a [scenario] and an artificial
/// [latency], so screens show their loading, empty and error states without
/// a server (D-18).
final class FakeConfig {
  const FakeConfig({this.scenario = FakeScenario.sample, this.latency});

  /// From `--dart-define=FAKE_SCENARIO=…` and `FAKE_LATENCY_MS=…`.
  factory FakeConfig.fromEnv() => FakeConfig(
    scenario: FakeScenario.parse(Env.fakeScenario),
    latency: const Duration(milliseconds: Env.fakeLatencyMs),
  );

  /// For tests: sample data, no delay.
  static const instant = FakeConfig(latency: Duration.zero);

  final FakeScenario scenario;

  /// Delay before each answer; null means none.
  final Duration? latency;

  bool get isEmpty => scenario == FakeScenario.empty;

  /// Waits [latency], then returns [data], or [empty] in the empty scenario
  /// (when given), or throws in the error scenario. Every fake method goes
  /// through here, so the scenarios behave the same everywhere.
  Future<T> answer<T>(
    String operation,
    T Function() data, {
    T Function()? empty,
  }) async {
    final delay = latency;
    if (delay != null && delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    switch (scenario) {
      case FakeScenario.error:
        throw RepositoryException('$operation failed (FAKE_SCENARIO=error)');
      case FakeScenario.empty when empty != null:
        return empty();
      case FakeScenario.empty:
      case FakeScenario.sample:
        return data();
    }
  }

  /// Like [answer] for lists: the empty scenario returns `[]`.
  Future<List<T>> answerList<T>(String operation, List<T> Function() data) =>
      answer(operation, data, empty: () => <T>[]);
}
