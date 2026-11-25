import 'package:classmeet/core/clock.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/notifications_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('11 notifications', (tester) async {
    final now = DateTime(2026, 11, 24, 19, 30);
    await renderScreen(
      tester,
      'home/11_notifications',
      const NotificationsScreen(),
      overrides: [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        clockProvider.overrideWithValue(() => now),
      ],
      fullPage: true,
    );
  });
}
