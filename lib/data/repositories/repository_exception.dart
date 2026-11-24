/// The one failure type repositories throw. Screens catch it (through
/// `AsyncValue.error`) and show `ErrorState`; they never see transport or
/// backend details. The fakes throw it in the `error` scenario.
final class RepositoryException implements Exception {
  const RepositoryException(this.message);

  /// Developer-facing detail, for logs and debug builds.
  final String message;

  @override
  String toString() => 'RepositoryException: $message';
}
