import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/assets/app_images.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asset test (task 0.9): every registered image and icon fallback is in the
/// bundle. Pixel sizes are checked by `dart run tool/check_assets.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every AppImages entry is bundled', () async {
    for (final image in AppImages.all) {
      final data = await rootBundle.load(image.path);
      expect(data.lengthInBytes, greaterThan(0), reason: image.path);
    }
  });

  test('every SVG fallback is bundled', () async {
    for (final path in AppIcons.svgFallbacks) {
      final svg = await rootBundle.loadString(path);
      expect(svg, contains('<svg'), reason: path);
    }
  });

  test('each Figma icon name maps to a distinct glyph, except aliases', () {
    final distinct = Map.of(AppIcons.byFigmaName)
      ..removeWhere((name, _) => AppIcons.aliasedFigmaNames.contains(name));
    expect(distinct.values.toSet().length, distinct.length);
    for (final alias in AppIcons.aliasedFigmaNames) {
      expect(AppIcons.byFigmaName, contains(alias));
    }
  });

  test('Figma icon names are kebab-case Lucide names', () {
    for (final name in AppIcons.byFigmaName.keys) {
      expect(name, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')), reason: name);
    }
  });
}
