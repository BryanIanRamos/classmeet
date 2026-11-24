import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_profile_repository.dart';
import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/onboarding/presentation/screens/learning_preferences_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('98 learning preferences', (tester) async {
    // The design shows Flashcards and Reading summaries chosen.
    final repo = FakeProfileRepository(FakeConfig.instant);
    await repo.saveOnboardingPrefs(
      const OnboardingPrefs(
        studyMethods: {StudyMethod.flashcards, StudyMethod.readingSummaries},
      ),
    );
    await renderScreen(
      tester,
      'onboarding/98_learning_preferences',
      const LearningPreferencesScreen(),
      overrides: [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });
}
