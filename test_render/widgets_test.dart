import 'dart:io';
import 'dart:typed_data';

import 'package:classmeet/core/dev/widget_gallery.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

/// Width and height from a PNG's IHDR chunk.
(int, int) pngSize(String path) {
  final header = ByteData.sublistView(File(path).readAsBytesSync(), 16, 24);
  return (header.getUint32(0), header.getUint32(4));
}

void main() {
  testWidgets('renders the widget gallery as a full page', (tester) async {
    await renderScreen(
      tester,
      'dev/widgets',
      const WidgetGallery(),
      fullPage: true,
      allowMissingImages: true, // the AppIllustration placeholder demo
    );

    for (final size in renderSizes) {
      final path = '$rendersDir/dev/widgets@${size.width.round()}.png';
      expect(File(path).existsSync(), true, reason: path);
      final (width, height) = pngSize(path);
      expect(width, size.width * renderPixelRatio);
      expect(height, greaterThan(size.height * renderPixelRatio));
    }
  });
}
