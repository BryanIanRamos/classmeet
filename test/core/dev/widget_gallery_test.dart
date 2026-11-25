import 'package:classmeet/app.dart';
import 'package:classmeet/core/dev/widget_gallery.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lays out without overflow at 360dp', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const WidgetGallery()),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the matrix shows every style, state and size', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AppButtonMatrix()),
      ),
    );

    final cells =
        AppButtonStyle.values.length *
        AppButtonMatrix.states.length *
        AppButtonSize.values.length;
    final tones = AppButtonTone.values.length * AppButtonStyle.values.length;
    // Plus one disabled button per disabled look.
    final looks = AppButtonDisabledLook.values.length;
    expect(find.byType(AppButton), findsNWidgets(cells * 2 + tones + looks));
    final disabled = tester
        .widgetList<TextButton>(find.byType(TextButton))
        .where((b) => !b.enabled);
    expect(disabled.length, cells * 2 ~/ AppButtonMatrix.states.length + looks);
  });

  testWidgets('opens at /dev/widgets in debug builds', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClassMeetApp(),
      ),
    );

    container.read(routerProvider).go('/dev/widgets');
    await tester.pumpAndSettle();

    expect(find.byType(WidgetGallery), findsOneWidget);
  });
}
