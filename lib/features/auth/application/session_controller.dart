import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/env.dart';

/// Where the user is in the sign-up journey. The router's onboarding gate
/// reads it: only [ready] users reach the tabs and detail flows.
enum SessionStatus {
  /// Not signed in: the app opens on the splash and welcome screens.
  signedOut,

  /// Signed up, but the onboarding steps (96–99) are not finished.
  onboarding,

  /// Signed in and onboarded.
  ready,
}

/// The status the app starts with. A normal launch starts signed out (there
/// is no persistence yet, Phase 10). Launching one screen for review with
/// `--dart-define=INITIAL_ROUTE=<route>` starts [SessionStatus.ready], so any
/// screen opens directly. Tests override this provider.
final initialSessionStatusProvider = Provider<SessionStatus>(
  (ref) =>
      Env.initialRoute == '/' ? SessionStatus.signedOut : SessionStatus.ready,
);

/// The current [SessionStatus]. The auth repository (task 3.6) will drive it;
/// until then the onboarding screens call these methods directly.
final sessionProvider = NotifierProvider<SessionController, SessionStatus>(
  SessionController.new,
);

class SessionController extends Notifier<SessionStatus> {
  @override
  SessionStatus build() => ref.watch(initialSessionStatusProvider);

  /// Sign up finished (3.1): the onboarding steps come next.
  void signedUp() => state = SessionStatus.onboarding;

  /// Log in with an onboarded account.
  void signedIn() => state = SessionStatus.ready;

  /// The last onboarding step (99) finished.
  void finishOnboarding() => state = SessionStatus.ready;

  void signOut() => state = SessionStatus.signedOut;
}
