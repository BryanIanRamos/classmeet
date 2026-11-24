import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_gradients.dart';
import 'package:classmeet/core/theme/app_shadows.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Values copied from design/specs/ds/shadow_5248-1829.md:
  // (y, blur, spread, alpha) for each of the two layers.
  const sheet = {
    '100': [(4, 4, -2, 0x14), (2, 4, -2, 0x1F)],
    '200': [(8, 8, -4, 0x14), (4, 6, -4, 0x1F)],
    '300': [(8, 16, -6, 0x14), (6, 8, -6, 0x1F)],
    '400': [(8, 24, -4, 0x14), (6, 12, -6, 0x1F)],
    '500': [(10, 32, -4, 0x1A), (6, 14, -6, 0x1F)],
    '600': [(12, 42, -4, 0x1F), (8, 18, -6, 0x1F)],
    '700': [(14, 64, -4, 0x1F), (8, 22, -6, 0x1F)],
    '800': [(18, 88, -4, 0x24), (8, 28, -6, 0x1F)],
  };

  test('shadows match the DS sheet', () {
    expect(AppShadows.byFigmaName.keys, sheet.keys);
    for (final MapEntry(key: level, value: layers) in sheet.entries) {
      final shadows = AppShadows.byFigmaName[level]!;
      expect(shadows.length, layers.length, reason: level);
      for (final (i, (y, blur, spread, alpha)) in layers.indexed) {
        final s = shadows[i];
        expect(s.offset, Offset(0, y.toDouble()), reason: '$level/$i');
        expect(s.blurRadius, blur, reason: '$level/$i blur');
        expect(s.spreadRadius, spread, reason: '$level/$i spread');
        expect(
          s.color.toARGB32(),
          alpha << 24 | (AppColors.grey900.toARGB32() & 0xFFFFFF),
          reason: '$level/$i colour',
        );
      }
    }
  });

  test('fade runs from the transparent tint to the tint', () {
    final fade = AppGradients.fade(AppColors.sprout100);
    expect(fade.begin, Alignment.topCenter);
    expect(fade.end, Alignment.bottomCenter);
    expect(fade.colors.last, AppColors.sprout100);
    expect(fade.colors.first.toARGB32(), 0x00D3F0DE);

    final sideways = AppGradients.fade(
      AppColors.white,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    expect(sideways.begin, Alignment.centerLeft);
  });
}
