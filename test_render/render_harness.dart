/// Headless renders for comparing screens with the Figma references.
///
/// ```
/// flutter test test_render/<section>_test.dart
/// ```
///
/// [renderScreen] writes `design/renders/<section>/<no>_<slug>@428.png` and
/// `@360.png` at DPR 2, the scale of `design/ref`. When
/// `design/ref/<section>/<no>_<slug>.png` exists it also writes
/// `@428_vs_ref.png`: the reference on the left, the render on the right.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Logical sizes rendered: the Figma base frame (428 × 870) first, then the
/// smallest supported phone (360 × 800).
const renderSizes = [Size(428, 870), Size(360, 800)];

/// Pixel ratio of the renders; matches the 2x Figma references.
const renderPixelRatio = 2.0;

/// Safe-area insets standing in for the chrome drawn in the Figma frames: the
/// 62-high iOS status bar and the 24-high home indicator (task 1.5).
const renderViewPadding = EdgeInsets.only(top: 62, bottom: 24);

const rendersDir = 'design/renders';
const refDir = 'design/ref';

final _boundary = GlobalKey(debugLabel: 'render boundary');

/// Renders [screen] at each of [renderSizes] and writes the PNGs (see the
/// library comment). [name] is `<section>/<no>_<slug>`, as in `design/ref`.
///
/// The screen runs inside a `ProviderScope` with [overrides] and retries
/// turned off (so error states show), under `AppTheme.light`.
///
/// Fails on overflow or any other error raised while building or painting.
/// [fullPage] grows the viewport to the scroll content's full height, like a
/// tall Figma frame. Set [settle] to false for screens with endless
/// animations, such as loaders.
Future<void> renderScreen(
  WidgetTester tester,
  String name,
  Widget screen, {
  List<Override> overrides = const [],
  bool fullPage = false,
  bool settle = true,
}) async {
  addTearDown(tester.view.reset);
  for (final size in renderSizes) {
    final width = size.width.round();
    await tester.pumpWidget(const SizedBox.shrink()); // fresh state per size
    await _pumpAt(tester, size, screen, overrides, settle: settle);
    if (fullPage) {
      final extra = _maxScrollExtent(tester);
      if (extra > 0) {
        final tall = Size(size.width, size.height + extra);
        await _pumpAt(tester, tall, screen, overrides, settle: settle);
      }
    }
    expect(tester.takeException(), isNull, reason: '$name at ${width}dp');

    final png = await _capture(tester);
    _write('$rendersDir/$name@$width.png', png);
    if (size == renderSizes.first) await _writeSideBySide(tester, name, png);
  }
}

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget screen,
  List<Override> overrides, {
  required bool settle,
}) async {
  final padding = FakeViewPadding(
    top: renderViewPadding.top * renderPixelRatio,
    bottom: renderViewPadding.bottom * renderPixelRatio,
  );
  tester.view
    ..devicePixelRatio = renderPixelRatio
    ..physicalSize = size * renderPixelRatio
    ..padding = padding
    ..viewPadding = padding;

  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: ProviderScope(
        overrides: overrides,
        retry: (_, _) => null,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: screen,
        ),
      ),
    ),
  );
  await _loadImages(tester);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Decodes every image on screen (asset loads are real I/O, which only
/// completes outside the test's fake clock).
Future<void> _loadImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image, skipOffstage: false).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
    final boxes = find.byType(DecoratedBox, skipOffstage: false).evaluate();
    for (final element in boxes) {
      final decoration = (element.widget as DecoratedBox).decoration;
      if (decoration case BoxDecoration(image: DecorationImage(:final image))) {
        await precacheImage(image, element);
      }
    }
  });
  await tester.pump();
}

/// The largest vertical scroll extent on screen, or 0.
double _maxScrollExtent(WidgetTester tester) {
  var extent = 0.0;
  final scrollables = find.byType(Scrollable, skipOffstage: false);
  for (final state in tester.stateList<ScrollableState>(scrollables)) {
    final position = state.position;
    if (position.axis == Axis.vertical && position.hasContentDimensions) {
      extent = math.max(extent, position.maxScrollExtent);
    }
  }
  return extent;
}

/// Captures the screen at [renderPixelRatio] (`captureImage` from
/// flutter_test always captures at 1x).
Future<Uint8List> _capture(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundary),
  );
  final png = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: renderPixelRatio);
    try {
      return await _encode(image);
    } finally {
      image.dispose();
    }
  });
  return png!;
}

Future<void> _writeSideBySide(
  WidgetTester tester,
  String name,
  Uint8List render,
) async {
  final ref = File('$refDir/$name.png');
  if (!ref.existsSync()) return;
  final refBytes = ref.readAsBytesSync();

  final png = await tester.runAsync(() async {
    final left = await _decode(refBytes);
    final right = await _decode(render);
    const gap = 24;
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..drawColor(AppColors.grey300, BlendMode.src)
      ..drawImage(left, Offset.zero, Paint())
      ..drawImage(right, Offset(left.width + gap.toDouble(), 0), Paint());
    final image = await recorder.endRecording().toImage(
      left.width + gap + right.width,
      math.max(left.height, right.height),
    );
    try {
      return await _encode(image);
    } finally {
      left.dispose();
      right.dispose();
      image.dispose();
    }
  });
  _write('$rendersDir/$name@428_vs_ref.png', png!);
}

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

Future<Uint8List> _encode(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void _write(String path, Uint8List bytes) {
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  debugPrint('render  $path');
}
