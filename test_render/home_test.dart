import 'package:classmeet/core/clock.dart';
import 'package:classmeet/core/router/app_bottom_nav.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

/// A tab root inside the shell's chrome, as `AppShell` lays it out: the
/// screen above the bottom nav, which takes the bottom inset.
class _InShell extends StatelessWidget {
  const _InShell(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: child,
            ),
          ),
          AppBottomNav(
            currentIndex: 0,
            onTabSelected: (_) {},
            createOpen: false,
            onCreatePressed: () {},
          ),
        ],
      ),
    );
  }
}

/// The design's "Good evening".
final _evening = DateTime(2026, 11, 24, 19, 30);

void main() {
  testWidgets('8 home dashboard', (tester) async {
    await renderScreen(
      tester,
      'home/8_home_dashboard',
      const _InShell(HomeDashboardScreen()),
      overrides: [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        clockProvider.overrideWithValue(() => _evening),
      ],
      fullPage: true, // the frame is 1098 tall
    );
  });
}
