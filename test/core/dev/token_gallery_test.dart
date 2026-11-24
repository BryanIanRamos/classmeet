import 'package:classmeet/app.dart';
import 'package:classmeet/core/dev/token_gallery.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpGallery(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const TokenGallery()),
    );
  }

  for (final size in const [Size(360, 800), Size(428, 926)]) {
    testWidgets('lays out without overflow at ${size.width.round()}dp', (
      tester,
    ) async {
      await pumpGallery(tester, size);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('lists every family, role and text style', (tester) async {
    await pumpGallery(tester, const Size(428, 926));

    for (final family in AppColors.families.keys) {
      expect(find.text(family), findsOneWidget, reason: family);
    }
    for (final role in AppSemanticColors.light.byFigmaName.keys) {
      expect(find.text(role), findsOneWidget, reason: role);
    }
    for (final name in AppTypography.byFigmaName.keys) {
      expect(find.textContaining('$name · '), findsOneWidget, reason: name);
    }
  });

  test('figmaHex uses the Figma notation (alpha last)', () {
    expect(figmaHex(AppColors.sage500), '#42807F');
    expect(figmaHex(AppColors.black10), '#0000001A');
    expect(figmaHex(AppSemanticColors.light.textSecondaryWhite), '#FFFFFF99');
  });

  testWidgets('opens at /dev/tokens in debug builds', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClassMeetApp(),
      ),
    );

    container.read(routerProvider).go('/dev/tokens');
    await tester.pumpAndSettle();

    expect(find.byType(TokenGallery), findsOneWidget);
  });
}
