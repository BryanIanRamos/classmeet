import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/search_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('12 search', (tester) async {
    // The design shows results with the placeholder; "i" matches every
    // sample, so the frame's three groups appear.
    await renderScreen(
      tester,
      'home/12_search',
      const SearchScreen(initialQuery: 'i'),
      overrides: [fakeConfigProvider.overrideWithValue(FakeConfig.instant)],
      fullPage: true,
    );
  });
}
