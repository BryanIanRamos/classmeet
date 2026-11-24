import 'package:classmeet/core/router/onboarding_gate.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

String? gate(SessionStatus status, String location) =>
    onboardingGate(status, Uri.parse(location));

void main() {
  group('root path', () {
    test('goes to the entry point of each status', () {
      expect(gate(SessionStatus.signedOut, '/'), Routes.splash);
      expect(gate(SessionStatus.onboarding, '/'), Routes.onboardingAcademic);
      expect(gate(SessionStatus.ready, '/'), Routes.home);
    });
  });

  group('gated paths', () {
    const gated = [
      Routes.home,
      Routes.notifications,
      Routes.studyClasses,
      '/study/reader/week-1?tab=visual',
      Routes.create,
      Routes.quizSource,
      Routes.play,
      '/play/run/attempt-1',
      Routes.friends,
      Routes.settings,
    ];

    test('send signed-out users to the splash', () {
      for (final path in gated) {
        expect(
          gate(SessionStatus.signedOut, path),
          Routes.splash,
          reason: path,
        );
      }
    });

    test('send users mid-onboarding to the first step', () {
      for (final path in gated) {
        expect(
          gate(SessionStatus.onboarding, path),
          Routes.onboardingAcademic,
          reason: path,
        );
      }
    });

    test('are open to ready users', () {
      for (final path in gated) {
        expect(gate(SessionStatus.ready, path), isNull, reason: path);
      }
    });
  });

  test('onboarding, auth and dev paths are always open', () {
    const open = [
      Routes.splash,
      Routes.welcome,
      Routes.signUp,
      Routes.login,
      Routes.carsuSignIn,
      Routes.terms,
      Routes.onboardingSubjects,
      Routes.onboardingRoutine,
      '/dev/widgets',
    ];
    for (final status in SessionStatus.values) {
      for (final path in open) {
        expect(gate(status, path), isNull, reason: '$status $path');
      }
    }
  });

  test('a prefix only matches whole path segments', () {
    expect(gate(SessionStatus.signedOut, '/homework'), isNull);
    expect(gate(SessionStatus.signedOut, '/players'), isNull);
  });
}
