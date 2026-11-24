import 'package:classmeet/core/theme/app_radii.dart';
import 'package:classmeet/core/theme/app_spacing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Values copied from design/notes/tokens.md.
  test('spacing matches the Figma padding scale', () {
    expect(AppSpacing.byFigmaName, {
      'none': 0,
      'xxs': 4,
      'xs': 8,
      'sm': 12,
      'md': 16,
      'lg': 20,
      'xl': 24,
    });
  });

  test('the Figma spacing (gap) values are on the scale', () {
    for (final gap in const [0, 12, 16]) {
      expect(AppSpacing.byFigmaName.values, contains(gap));
    }
  });

  test('radii match the Figma corner-radius scale', () {
    expect(AppRadii.byFigmaName, {
      'none': 0,
      'xs': 8,
      'sm': 12,
      'md': 16,
      'lg': 20,
      'xl': 24,
      'xxl': 32,
      '5xl': 64,
    });
  });
}
