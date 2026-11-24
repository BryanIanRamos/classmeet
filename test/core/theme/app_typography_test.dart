import 'package:classmeet/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Spec = ({String family, double size, double lineHeight, int weight});

void main() {
  const jakarta = 'PlusJakartaSans';
  const inter = 'Inter';

  // Values copied from design/notes/tokens.md (Figma text styles), plus the
  // two unnamed styles found on the screens in task 1.5.
  const specs = <String, Spec>{
    'Headings/H1': (family: jakarta, size: 48, lineHeight: 58, weight: 600),
    'Headings/H2': (family: jakarta, size: 40, lineHeight: 48, weight: 600),
    'Headings/H3': (family: jakarta, size: 32, lineHeight: 38, weight: 600),
    'Headings/H3 ExtraBold': (
      family: jakarta,
      size: 32,
      lineHeight: 38,
      weight: 800,
    ),
    'Headings/H5': (family: jakarta, size: 24, lineHeight: 28, weight: 600),
    'Subtitle/S1': (family: jakarta, size: 18, lineHeight: 28, weight: 600),
    'Subtitle/S2': (family: jakarta, size: 16, lineHeight: 24, weight: 600),
    'Body/B1': (family: jakarta, size: 16, lineHeight: 24, weight: 400),
    'Body/B2': (family: jakarta, size: 16, lineHeight: 24, weight: 500),
    'Body/B3': (family: jakarta, size: 14, lineHeight: 20, weight: 400),
    'Body/B4': (family: jakarta, size: 14, lineHeight: 20, weight: 500),
    'Caption/C1': (family: jakarta, size: 12, lineHeight: 16, weight: 400),
    'Caption/C2': (family: jakarta, size: 12, lineHeight: 16, weight: 500),
    'Caption/C3': (family: jakarta, size: 10, lineHeight: 14, weight: 400),
    'Caption/C3 Medium': (
      family: jakarta,
      size: 10,
      lineHeight: 14,
      weight: 500,
    ),
    'Button/Giant': (family: jakarta, size: 18, lineHeight: 24, weight: 600),
    'Button/Large': (family: jakarta, size: 16, lineHeight: 20, weight: 600),
    'Button/Medium': (family: jakarta, size: 14, lineHeight: 16, weight: 600),
    'Button/Small': (family: jakarta, size: 12, lineHeight: 16, weight: 600),
    'Button/Tiny': (family: jakarta, size: 10, lineHeight: 12, weight: 600),
    'Text Font/C1 Caption': (
      family: inter,
      size: 12,
      lineHeight: 16,
      weight: 400,
    ),
    'Text Font/B1 Body': (family: inter, size: 16, lineHeight: 24, weight: 400),
  };

  // Weights bundled in pubspec.yaml (task 0.7).
  const bundled = {
    jakarta: {400, 500, 600, 700, 800},
    inter: {400, 500},
  };

  test('has exactly the Figma styles', () {
    expect(AppTypography.byFigmaName.keys, specs.keys);
  });

  for (final MapEntry(key: name, value: spec) in specs.entries) {
    test('$name matches tokens.md', () {
      final style = AppTypography.byFigmaName[name]!;
      expect(style.fontFamily, spec.family);
      expect(style.fontSize, spec.size);
      expect(style.height! * style.fontSize!, closeTo(spec.lineHeight, 1e-9));
      expect(style.fontWeight!.value, spec.weight);
      expect(style.letterSpacing, 0);
      expect(style.leadingDistribution, TextLeadingDistribution.even);
      expect(style.color, isNull, reason: 'styles inherit their colour');
    });
  }

  test('every style uses a bundled family and weight', () {
    for (final MapEntry(key: name, value: style)
        in AppTypography.byFigmaName.entries) {
      expect(
        bundled[style.fontFamily],
        contains(style.fontWeight!.value),
        reason: name,
      );
    }
  });

  testWidgets('one line of text is exactly the Figma line height', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final MapEntry(key: name, value: style)
                in AppTypography.byFigmaName.entries)
              Text('Ag', key: ValueKey(name), style: style),
          ],
        ),
      ),
    );

    for (final MapEntry(key: name, value: spec) in specs.entries) {
      final size = tester.getSize(find.byKey(ValueKey(name)));
      expect(size.height, closeTo(spec.lineHeight, 0.01), reason: name);
    }
  });
}
