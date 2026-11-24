import 'package:classmeet/core/dev/galleries/illustration_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden of AppIllustration, the Home illustrated cards (placeholders until
/// task 1.8) and the ComingSoonScreen. Regenerate with
/// `flutter test --update-goldens test/goldens/illustration_golden_test.dart`.
void main() {
  testWidgets('illustration matrix', (tester) async {
    await tester.binding.setSurfaceSize(const Size(820, 1250));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(child: IllustrationMatrix()),
          ),
        ),
      ),
    );
    // Asset decoding is real I/O: let it finish outside the fake clock.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final image = (element.widget as Image).image;
        await precacheImage(image, element, onError: (_, _) {});
      }
    });
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(IllustrationMatrix),
      matchesGoldenFile('illustration.png'),
    );
  });
}
