import 'package:classmeet/core/clock.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/talon_credits_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('14 talon credits', (tester) async {
    // The balance card art and the quest card waves are manual exports (1.8):
    // the cards render as their plain fills.
    final now = DateTime(2026, 11, 24, 19, 30);
    await renderScreen(
      tester,
      'home/14_talon_credits',
      const TalonCreditsScreen(),
      overrides: [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        clockProvider.overrideWithValue(() => now),
      ],
      fullPage: true,
    );
  });
}
