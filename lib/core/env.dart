/// Build-time flags, set with `--dart-define=NAME=value`.
///
/// ```
/// flutter run --dart-define=INITIAL_ROUTE=/home --dart-define=FAKE_SCENARIO=empty
/// ```
abstract final class Env {
  /// Route the app opens on. Used to launch a single screen for review.
  static const initialRoute = String.fromEnvironment(
    'INITIAL_ROUTE',
    defaultValue: '/',
  );

  /// Sample-data scenario for the fake repositories: `default`, `empty` or
  /// `error`.
  static const fakeScenario = String.fromEnvironment(
    'FAKE_SCENARIO',
    defaultValue: 'default',
  );

  /// Artificial latency for fake repositories, in milliseconds.
  static const fakeLatencyMs = int.fromEnvironment(
    'FAKE_LATENCY_MS',
    defaultValue: 300,
  );

  /// Where data comes from: `fake` (sample data) or `remote` (backend, Phase 11).
  static const dataSource = String.fromEnvironment(
    'DATA_SOURCE',
    defaultValue: 'fake',
  );
}
