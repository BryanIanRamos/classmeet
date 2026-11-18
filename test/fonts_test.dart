import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Font smoke test (task 0.7): every bundled font is registered in the
/// font manifest with the expected weights and loads as a TrueType file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = {
    'PlusJakartaSans': {
      400: 'assets/fonts/PlusJakartaSans-Regular.ttf',
      500: 'assets/fonts/PlusJakartaSans-Medium.ttf',
      600: 'assets/fonts/PlusJakartaSans-SemiBold.ttf',
      700: 'assets/fonts/PlusJakartaSans-Bold.ttf',
    },
    'Inter': {
      400: 'assets/fonts/Inter-Regular.ttf',
      500: 'assets/fonts/Inter-Medium.ttf',
    },
  };

  test('font manifest registers each family and weight', () async {
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
    final families = {
      for (final entry in manifest.cast<Map<String, dynamic>>())
        if (expected.containsKey(entry['family']))
          entry['family'] as String: {
            for (final font
                in (entry['fonts'] as List).cast<Map<String, dynamic>>())
              font['weight'] as int: font['asset'] as String,
          },
    };

    for (final MapEntry(key: family, value: weights) in expected.entries) {
      expect(families[family], weights, reason: family);
    }
  });

  test('every font file loads as TrueType', () async {
    for (final path in expected.values.expand((w) => w.values)) {
      final bytes = (await rootBundle.load(path)).buffer.asUint8List();
      expect(bytes.sublist(0, 4), [0, 1, 0, 0], reason: path);
    }
  });
}
