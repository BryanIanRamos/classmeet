import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/onboarding/presentation/screens/academic_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('96 academic profile', (tester) async {
    await renderScreen(
      tester,
      'onboarding/96_academic_profile',
      const AcademicProfileScreen(),
      overrides: [fakeConfigProvider.overrideWithValue(FakeConfig.instant)],
    );
  });
}
