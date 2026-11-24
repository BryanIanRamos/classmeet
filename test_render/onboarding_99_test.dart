import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_routine_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('99 study routine', (tester) async {
    await renderScreen(
      tester,
      'onboarding/99_study_routine',
      const StudyRoutineScreen(),
      overrides: [fakeConfigProvider.overrideWithValue(FakeConfig.instant)],
      fullPage: true, // the frame is 947 tall
    );
  });
}
