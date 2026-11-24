import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/onboarding/application/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> loaded({
  FakeConfig config = FakeConfig.instant,
}) async {
  final container = ProviderContainer(
    overrides: [
      fakeConfigProvider.overrideWithValue(config),
      initialSessionStatusProvider.overrideWithValue(SessionStatus.onboarding),
    ],
  );
  addTearDown(container.dispose);
  await container.read(onboardingControllerProvider.future);
  return container;
}

OnboardingPrefs prefsOf(ProviderContainer c) =>
    c.read(onboardingControllerProvider).requireValue;

OnboardingController controllerOf(ProviderContainer c) =>
    c.read(onboardingControllerProvider.notifier);

void main() {
  test('loads the saved prefs (the school from the profile)', () async {
    final c = await loaded();
    expect(prefsOf(c).schoolId, 'csu');
    expect(prefsOf(c).academicComplete, isFalse);
  });

  test('changing the school clears college and program', () async {
    final c = await loaded();
    controllerOf(c)
      ..selectCollege('csu-ccis')
      ..selectProgram('csu-bsit')
      ..selectYearLevel(YearLevel.second);
    expect(prefsOf(c).academicComplete, isTrue);

    controllerOf(c).selectSchool('fsuu');
    expect(prefsOf(c).schoolId, 'fsuu');
    expect(prefsOf(c).collegeId, isNull);
    expect(prefsOf(c).programId, isNull);
    expect(prefsOf(c).yearLevel, YearLevel.second, reason: 'kept');
  });

  test('changing the college clears the program only', () async {
    final c = await loaded();
    controllerOf(c)
      ..selectCollege('csu-ccis')
      ..selectProgram('csu-bsit')
      ..selectCollege('csu-coe');
    expect(prefsOf(c).collegeId, 'csu-coe');
    expect(prefsOf(c).programId, isNull);
    expect(prefsOf(c).schoolId, 'csu');
  });

  test('subjects toggle on and off', () async {
    final c = await loaded();
    controllerOf(c)
      ..toggleSubject('a')
      ..toggleSubject('b')
      ..toggleSubject('a');
    expect(prefsOf(c).subjectIds, {'b'});
  });

  test('study methods stop at three (98)', () async {
    final c = await loaded();
    final controller = controllerOf(c);
    for (final method in StudyMethod.values) {
      controller.toggleStudyMethod(method);
    }
    expect(prefsOf(c).studyMethods, hasLength(OnboardingPrefs.maxStudyMethods));
    controller.toggleStudyMethod(prefsOf(c).studyMethods.first);
    expect(prefsOf(c).studyMethods, hasLength(2));
  });

  test('finish saves the answers and marks the session ready', () async {
    final c = await loaded();
    controllerOf(c)
      ..selectCollege('csu-ccis')
      ..selectLanguage(LearningLanguage.taglish);
    await controllerOf(c).finish();

    expect(c.read(sessionProvider), SessionStatus.ready);
    final saved = await c
        .read(profileRepositoryProvider)
        .fetchOnboardingPrefs();
    expect(saved.collegeId, 'csu-ccis');
    expect(saved.language, LearningLanguage.taglish);
  });

  test('a failed load ignores edits and reports the error', () async {
    final c = ProviderContainer(
      overrides: [
        fakeConfigProvider.overrideWithValue(
          const FakeConfig(
            scenario: FakeScenario.error,
            latency: Duration.zero,
          ),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(c.dispose);
    await expectLater(
      c.read(onboardingControllerProvider.future),
      throwsA(anything),
    );
    controllerOf(c).selectYearLevel(YearLevel.first);
    expect(c.read(onboardingControllerProvider).hasError, isTrue);
  });
}
