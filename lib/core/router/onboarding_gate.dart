import '../../features/auth/application/session_controller.dart';
import 'routes.dart';

/// The router's redirect, as a pure function so it can be tested alone.
///
/// - `/` goes to Home when the user is ready, otherwise to the splash (or the
///   first onboarding step if sign-up is done).
/// - Gated paths (tabs and detail flows, [Routes.gatedPrefixes]) send users
///   who are not ready back to the same place.
/// - Onboarding, auth and `/dev` paths are always open, so the flow can go
///   back and forth and single screens can be launched for review.
///
/// Returns null to stay on [location].
String? onboardingGate(SessionStatus status, Uri location) {
  final path = location.path;
  final entry = switch (status) {
    SessionStatus.signedOut => Routes.splash,
    SessionStatus.onboarding => Routes.onboardingAcademic,
    SessionStatus.ready => Routes.home,
  };
  if (path == '/' || path.isEmpty) return entry;
  if (status == SessionStatus.ready) return null;
  final gated = Routes.gatedPrefixes.any(
    (prefix) => path == prefix || path.startsWith('$prefix/'),
  );
  return gated ? entry : null;
}
