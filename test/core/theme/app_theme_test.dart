import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = AppTheme.light;

  test('carries the semantic colour roles', () {
    expect(theme.extension<AppSemanticColors>(), same(AppSemanticColors.light));
  });

  test('maps the palette onto the Material colour scheme', () {
    final scheme = theme.colorScheme;
    expect(scheme.brightness, Brightness.light);
    expect(scheme.primary, AppColors.sage500);
    expect(scheme.secondary, AppColors.plume500);
    expect(scheme.error, AppColors.ember500);
    expect(scheme.surface, AppColors.white);
    expect(scheme.onSurface, AppColors.grey900);
    expect(scheme.surfaceTint, Colors.transparent);
    expect(theme.scaffoldBackgroundColor, AppColors.white);
  });

  test('every text theme style comes from the type scale', () {
    final scale = AppTypography.byFigmaName.values
        .map((s) => (s.fontSize, s.height, s.fontWeight))
        .toSet();
    final textTheme = theme.textTheme;
    final styles = [
      textTheme.displayLarge,
      textTheme.displayMedium,
      textTheme.displaySmall,
      textTheme.headlineLarge,
      textTheme.headlineMedium,
      textTheme.headlineSmall,
      textTheme.titleLarge,
      textTheme.titleMedium,
      textTheme.titleSmall,
      textTheme.bodyLarge,
      textTheme.bodyMedium,
      textTheme.bodySmall,
      textTheme.labelLarge,
      textTheme.labelMedium,
      textTheme.labelSmall,
    ];
    for (final style in styles) {
      expect(style!.fontFamily, AppTypography.jakarta);
      expect(scale, contains((style.fontSize, style.height, style.fontWeight)));
      expect(style.color, AppSemanticColors.light.textPrimary);
    }
  });

  testWidgets('plain Text renders as Body/B3 in text-primary-black', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(body: Text('Hello')),
      ),
    );

    final style = tester.widget<RichText>(find.byType(RichText)).text.style!;
    expect(style.fontFamily, AppTypography.jakarta);
    expect(style.fontSize, AppTypography.b3.fontSize);
    expect(style.height, AppTypography.b3.height);
    expect(style.fontWeight, AppTypography.b3.fontWeight);
    expect(style.color, AppSemanticColors.light.textPrimary);
  });
}
