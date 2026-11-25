import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
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
      // The design shows the field focused (Sage border).
      // Focus the field, then hide the caret handle a focused non-empty
      // field shows (the design has none).
      prepare: (tester) async {
        final field = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        field.widget.focusNode.requestFocus();
        await tester.pump();
        field.hideToolbar();
      },
    );
  });
}
