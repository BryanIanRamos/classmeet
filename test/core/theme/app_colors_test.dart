import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Figma hex (`#RRGGBB` or `#RRGGBBAA`, alpha last) → ARGB int.
int figmaHex(String hex) {
  final digits = hex.substring(1);
  final rgb = int.parse(digits.substring(0, 6), radix: 16);
  final alpha = digits.length == 8
      ? int.parse(digits.substring(6), radix: 16)
      : 0xFF;
  return alpha << 24 | rgb;
}

Map<K, int> argb<K>(Map<K, Color> colors) => {
  for (final MapEntry(:key, :value) in colors.entries) key: value.toARGB32(),
};

Map<K, int> expected<K>(Map<K, String> hexes) => {
  for (final MapEntry(:key, :value) in hexes.entries) key: figmaHex(value),
};

void main() {
  // Values copied from design/notes/tokens.md (Figma variables, 2026-11-19).
  group('palette', () {
    const families = {
      'Sage': {
        50: '#EDF5F4',
        100: '#D9EAE8',
        300: '#94BDB8',
        500: '#42807F',
        700: '#2B5756',
        900: '#173332',
      },
      'Plume': {50: '#E6F1F4', 100: '#C5E0E6', 300: '#6F9DA8', 500: '#084457'},
      'Talon': {
        50: '#FFFAED',
        100: '#FFF2D6',
        300: '#FFD77F',
        500: '#FFC457',
        700: '#B77B21',
        900: '#5D3D15',
      },
      'Ember': {
        50: '#FFF2EF',
        100: '#FFDCD5',
        300: '#FF9D8B',
        500: '#FF5A3B',
        700: '#CC4830',
      },
      'Sprout': {
        50: '#ECF9F1',
        100: '#D3F0DE',
        300: '#8BD0A5',
        500: '#45B978',
        700: '#35935E',
        900: '#287247',
      },
      'Sky': {
        50: '#F0F7F9',
        100: '#D9E6F0',
        300: '#A5C6D5',
        500: '#74A7BB',
        700: '#598AA3',
        900: '#466382',
      },
      'Grey': {
        50: '#F9FAFB',
        100: '#F3F4F6',
        200: '#E5E7EA',
        300: '#D2D5DB',
        400: '#9EA2AE',
        500: '#6D717F',
        600: '#4D5461',
        900: '#131927',
      },
    };

    test('has exactly the Figma families', () {
      expect(AppColors.families.keys, families.keys);
    });

    for (final MapEntry(key: family, value: shades) in families.entries) {
      test('$family shades match tokens.md', () {
        expect(argb(AppColors.families[family]!), expected(shades));
      });
    }

    test('overlays match tokens.md', () {
      expect(
        argb(AppColors.overlays),
        expected({
          'White 100%': '#FFFFFF',
          'Labels/Primary': '#000000',
          'Black 10%': '#0000001A',
          'Black 30%': '#0000004D',
          'Black 50%': '#00000080',
          'White 10%': '#FFFFFF1A',
        }),
      );
    });
  });

  group('semantic roles', () {
    const roles = {
      'text-primary-black': '#131927',
      'text-secondary-dark-grey': '#6D717F',
      'text-grey': '#9EA2AE',
      'text-light-grey': '#D2D5DB',
      'text-disabled': '#E5E7EA',
      'text-primary-white': '#FFFFFF',
      'text-secondary-white': '#FFFFFF99',
      'text-accent': '#084457',
      'text-secondary-accent': '#42807F',
      'text-links': '#6F9DA8',
      'text-success': '#45B978',
      'text-warning': '#FFC457',
      'icon-black': '#131927',
      'icon-grey': '#9EA2AE',
      'icon-light-grey': '#D2D5DB',
      'icon-disabled': '#E5E7EA',
      'icon-white': '#FFFFFF',
      'icon-accent': '#084457',
      'icon-secondary-accent': '#42807F',
      'icon-success': '#45B978',
      'icon-warning': '#FFC457',
      'surface-white': '#FFFFFF',
      'surface-light-grey': '#F9FAFB',
    };

    test('light roles match tokens.md', () {
      expect(argb(AppSemanticColors.light.byFigmaName), expected(roles));
    });

    test('copyWith replaces only the given role', () {
      const light = AppSemanticColors.light;
      final changed = light.copyWith(textPrimary: AppColors.ember500);

      expect(changed.textPrimary, AppColors.ember500);
      final rest = {...changed.byFigmaName}..remove('text-primary-black');
      final original = {...light.byFigmaName}..remove('text-primary-black');
      expect(rest, original);
    });

    test('lerp returns the end points at 0 and 1', () {
      const light = AppSemanticColors.light;
      final other = light.copyWith(
        textPrimary: AppColors.white,
        surfaceLightGrey: AppColors.black,
      );

      expect(argb(light.lerp(other, 0).byFigmaName), argb(light.byFigmaName));
      expect(argb(light.lerp(other, 1).byFigmaName), argb(other.byFigmaName));
      expect(light.lerp(null, 0.5), same(light));
    });
  });

  group('context.colors', () {
    Future<AppSemanticColors> read(WidgetTester tester, ThemeData theme) async {
      late AppSemanticColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              colors = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      return colors;
    }

    testWidgets('reads the theme extension', (tester) async {
      final custom = AppSemanticColors.light.copyWith(
        textAccent: AppColors.ember500,
      );
      final colors = await read(tester, ThemeData(extensions: [custom]));
      expect(colors.textAccent, AppColors.ember500);
    });

    testWidgets('falls back to the light roles', (tester) async {
      final colors = await read(tester, ThemeData());
      expect(colors, same(AppSemanticColors.light));
    });
  });
}
