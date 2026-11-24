import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads every font in the app's `FontManifest.json` into the test engine:
/// the bundled Plus Jakarta Sans and Inter, and package fonts such as the
/// Lucide icons. Without this, tests draw every glyph with the test font, so
/// renders and goldens would not show the real type.
Future<void> loadAppFonts() async {
  final manifest =
      (jsonDecode(await rootBundle.loadString('FontManifest.json'))
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
  for (final entry in manifest) {
    final loader = FontLoader(entry['family'] as String);
    final fonts = (entry['fonts'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final font in fonts) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}
