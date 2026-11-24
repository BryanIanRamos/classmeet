import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/onboarding/application/onboarding_controller.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_subjects_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

/// Starts with the three subjects the design shows as picked.
class _PickedPrefs extends OnboardingController {
  @override
  Future<OnboardingPrefs> build() async => const OnboardingPrefs(
    subjectIds: {'computer-programming', 'intro-computing', 'hci'},
  );
}

void main() {
  testWidgets('97 study subjects', (tester) async {
    await renderScreen(
      tester,
      'onboarding/97_study_subjects',
      const StudySubjectsScreen(),
      overrides: [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        onboardingControllerProvider.overrideWith(_PickedPrefs.new),
      ],
    );
  });
}
