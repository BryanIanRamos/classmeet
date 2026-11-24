import 'dart:io';
import 'dart:typed_data';

import 'package:classmeet/core/dev/token_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

/// Width and height from a PNG's IHDR chunk.
(int, int) pngSize(String path) {
  final header = ByteData.sublistView(File(path).readAsBytesSync(), 16, 24);
  return (header.getUint32(0), header.getUint32(4));
}

void main() {
  testWidgets('renders the token gallery as a full page', (tester) async {
    await renderScreen(
      tester,
      'dev/tokens',
      const TokenGallery(),
      fullPage: true,
    );

    for (final size in renderSizes) {
      final (width, height) = pngSize(
        '$rendersDir/dev/tokens@${size.width.round()}.png',
      );
      expect(width, size.width * renderPixelRatio);
      expect(height, greaterThan(size.height * renderPixelRatio));
    }
  });

  testWidgets('fails when a screen overflows', (tester) async {
    const tooWide = Scaffold(
      body: Row(children: [SizedBox(width: 1000, height: 10)]),
    );
    Object? failure;
    try {
      await renderScreen(tester, 'dev/overflow_check', tooWide);
    } on TestFailure catch (e) {
      failure = e;
    }

    expect(failure, isA<TestFailure>());
    expect('$failure', contains('overflowed'));
    expect(File('$rendersDir/dev/overflow_check@428.png').existsSync(), false);
  });
}
