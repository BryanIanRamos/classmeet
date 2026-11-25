import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_radii.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpButton(WidgetTester tester, Widget button) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: button)),
    ),
  );
}

/// The background colour the button is currently painted with.
Color? paintedBackground(WidgetTester tester) => tester
    .widget<Material>(
      find.descendant(
        of: find.byType(TextButton),
        matching: find.byType(Material),
      ),
    )
    .color;

void main() {
  const colors = AppSemanticColors.light;

  group('geometry (DS Button 5248:660)', () {
    for (final size in AppButtonSize.values) {
      testWidgets('${size.name}: height, padding, icons and label gap', (
        tester,
      ) async {
        await pumpButton(
          tester,
          AppButton(
            label: 'Button',
            onPressed: () {},
            size: size,
            leadingIcon: AppIcons.arrowLeft,
            trailingIcon: AppIcons.arrowRight,
          ),
        );

        final button = tester.getSize(find.byType(TextButton));
        final text = tester.getSize(find.text('Button'));
        expect(button.height, size.height);
        expect(
          button.width,
          2 * size.padding +
              2 * size.iconSize +
              2 * AppButton.labelPadding +
              text.width,
        );
        expect(
          tester.getSize(find.byIcon(AppIcons.arrowLeft)),
          Size.square(size.iconSize),
        );
      });

      testWidgets('${size.name}: icon-only is square', (tester) async {
        await pumpButton(
          tester,
          AppButton.icon(
            icon: AppIcons.arrowUp,
            semanticLabel: 'Up',
            onPressed: () {},
            size: size,
          ),
        );
        expect(
          tester.getSize(find.byType(TextButton)),
          Size.square(size.height),
        );
      });
    }

    test('measurements match the DS component', () {
      expect(
        {
          for (final s in AppButtonSize.values)
            s.name: (s.height, s.padding, s.iconSize),
        },
        {
          'giant': (56, 24, 24),
          'large': (48, 20, 24),
          'medium': (40, 16, 24),
          'small': (32, 12, 24),
          'tiny': (24, 8, 16),
        },
      );
    });

    test('every size is a pill (radius 32)', () {
      final shape =
          const AppButton(
                label: 'x',
                onPressed: null,
              ).buttonStyle(colors).shape!.resolve({})
              as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        const BorderRadius.all(Radius.circular(AppRadii.xxl)),
      );
    });
  });

  group('colours per style and state', () {
    const states = {
      'default': <WidgetState>{},
      'hover': {WidgetState.hovered},
      'focus': {WidgetState.focused},
      'press': {WidgetState.pressed},
      'disabled': {WidgetState.disabled},
    };
    const ring = BorderSide(
      color: AppColors.sage300,
      width: AppButton.focusBorderWidth,
    );
    const outline = BorderSide(
      color: AppColors.sage500,
      width: AppButton.outlineBorderWidth,
    );
    const outlineDisabled = BorderSide(
      color: AppColors.grey200,
      width: AppButton.outlineBorderWidth,
    );
    const transparent = Colors.transparent;

    // (background, foreground, border) per state, in the order of `states`.
    final expected = {
      AppButtonStyle.filled: [
        (AppColors.sage500, colors.textPrimaryWhite, BorderSide.none),
        (AppColors.sage700, colors.textPrimaryWhite, BorderSide.none),
        (AppColors.sage500, colors.textPrimaryWhite, ring),
        (AppColors.sage900, colors.textPrimaryWhite, BorderSide.none),
        (AppColors.grey200, colors.textGrey, BorderSide.none),
      ],
      AppButtonStyle.outline: [
        (transparent, colors.textSecondaryAccent, outline),
        (AppColors.sage50, colors.textSecondaryAccent, outline),
        (transparent, colors.textSecondaryAccent, ring),
        (AppColors.sage100, colors.textSecondaryAccent, outline),
        (transparent, colors.textGrey, outlineDisabled),
      ],
      AppButtonStyle.clear: [
        (transparent, colors.textSecondaryAccent, BorderSide.none),
        (AppColors.sage50, colors.textSecondaryAccent, BorderSide.none),
        (transparent, colors.textSecondaryAccent, ring),
        (AppColors.sage100, colors.textSecondaryAccent, BorderSide.none),
        (transparent, colors.textGrey, BorderSide.none),
      ],
    };

    for (final MapEntry(key: style, value: rows) in expected.entries) {
      test(style.name, () {
        final buttonStyle = AppButton(
          label: 'x',
          onPressed: null,
          style: style,
        ).buttonStyle(colors);
        for (final (i, MapEntry(key: name, value: set))
            in states.entries.indexed) {
          final (background, foreground, side) = rows[i];
          expect(
            buttonStyle.backgroundColor!.resolve(set),
            background,
            reason: '$name background',
          );
          expect(
            buttonStyle.foregroundColor!.resolve(set),
            foreground,
            reason: '$name foreground',
          );
          expect(
            buttonStyle.iconColor!.resolve(set),
            foreground,
            reason: '$name icon',
          );
          expect(buttonStyle.side!.resolve(set), side, reason: '$name side');
        }
      });
    }
  });

  group('interaction', () {
    testWidgets('a tap calls onPressed once', (tester) async {
      var taps = 0;
      await pumpButton(
        tester,
        AppButton(label: 'Continue', onPressed: () => taps++),
      );
      await tester.tap(find.text('Continue'));
      expect(taps, 1);
    });

    testWidgets('a disabled button ignores taps', (tester) async {
      await pumpButton(
        tester,
        const AppButton(label: 'Continue', onPressed: null),
      );
      await tester.tap(find.text('Continue'), warnIfMissed: false);
      expect(paintedBackground(tester), AppColors.grey200);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).enabled,
        isFalse,
      );
    });

    testWidgets('hover and press repaint the filled background', (
      tester,
    ) async {
      await pumpButton(tester, AppButton(label: 'Go', onPressed: () {}));
      expect(paintedBackground(tester), AppColors.sage500);

      final center = tester.getCenter(find.byType(TextButton));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: center);
      addTearDown(mouse.removePointer);
      await tester.pump();
      expect(paintedBackground(tester), AppColors.sage700);

      await mouse.down(center);
      await tester.pump();
      expect(paintedBackground(tester), AppColors.sage900);
      await mouse.up();
    });

    testWidgets('a states controller shows a state without interaction', (
      tester,
    ) async {
      final controller = WidgetStatesController({WidgetState.pressed});
      addTearDown(controller.dispose);
      await pumpButton(
        tester,
        AppButton(
          label: 'Go',
          onPressed: () {},
          style: AppButtonStyle.outline,
          statesController: controller,
        ),
      );
      expect(paintedBackground(tester), AppColors.sage100);
    });
  });

  group('content and layout', () {
    testWidgets('icon-only carries its semantic label', (tester) async {
      await pumpButton(
        tester,
        AppButton.icon(
          icon: AppIcons.plus,
          semanticLabel: 'Create',
          onPressed: () {},
        ),
      );
      expect(find.bySemanticsLabel('Create'), findsOneWidget);
    });

    testWidgets('expand fills the available width', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Continue studying',
                onPressed: () {},
                expand: true,
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(TextButton)).width, 360 - 32);
    });

    testWidgets('a long label ellipsizes instead of overflowing at 360', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpButton(
        tester,
        AppButton(
          label: 'A very long label that cannot fit on a small phone screen',
          onPressed: () {},
          size: AppButtonSize.giant,
          leadingIcon: AppIcons.arrowLeft,
          trailingIcon: AppIcons.arrowRight,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(TextButton)).width,
        lessThanOrEqualTo(360),
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.textContaining('A very long label'),
      );
      expect(paragraph.didExceedMaxLines, isTrue, reason: 'ellipsized');
    });
  });
  group('tones', () {
    ButtonStyle styleOf(AppButtonStyle style, AppButtonTone tone) => AppButton(
      label: 'Tone',
      onPressed: () {},
      style: style,
      tone: tone,
    ).buttonStyle(colors);

    test('filled uses the tone ramp; label stays white', () {
      for (final tone in AppButtonTone.values) {
        final style = styleOf(AppButtonStyle.filled, tone);
        expect(style.backgroundColor!.resolve({}), tone.base, reason: '$tone');
        expect(
          style.backgroundColor!.resolve({WidgetState.pressed}),
          tone.pressed,
          reason: '$tone',
        );
        expect(style.foregroundColor!.resolve({}), AppColors.white);
        expect(
          style.side!.resolve({WidgetState.focused})!.color,
          tone.focusRing,
        );
      }
    });

    test('outline uses the tone for border and label (95: Plume-500)', () {
      final style = styleOf(AppButtonStyle.outline, AppButtonTone.plume);
      expect(style.side!.resolve({})!.color, AppColors.plume500);
      expect(style.foregroundColor!.resolve({}), AppColors.plume500);
      expect(
        style.backgroundColor!.resolve({WidgetState.pressed}),
        AppColors.plume100,
      );
    });

    test('sage stays the default', () {
      final style = AppButton(
        label: 'Default',
        onPressed: () {},
      ).buttonStyle(colors);
      expect(style.backgroundColor!.resolve({}), AppColors.sage500);
    });

    test('sky is Sky-900 so white passes contrast (14 "Answer survey")', () {
      final style = styleOf(AppButtonStyle.filled, AppButtonTone.sky);
      expect(style.backgroundColor!.resolve({}), AppColors.sky900);
      expect(
        style.backgroundColor!.resolve({WidgetState.pressed}),
        AppColors.sky900,
      );
    });

    test('disabled looks: muted, toned (claimed) and light (locked)', () {
      ButtonStyle off(AppButtonDisabledLook look) => AppButton(
        label: 'Off',
        onPressed: null,
        disabledLook: look,
      ).buttonStyle(colors);
      const disabled = {WidgetState.disabled};
      final muted = off(AppButtonDisabledLook.muted);
      expect(muted.backgroundColor!.resolve(disabled), AppColors.grey200);
      expect(muted.foregroundColor!.resolve(disabled), colors.textGrey);
      final toned = off(AppButtonDisabledLook.toned);
      expect(toned.backgroundColor!.resolve(disabled), AppColors.sage500);
      expect(toned.foregroundColor!.resolve(disabled), AppColors.white);
      final light = off(AppButtonDisabledLook.light);
      expect(light.backgroundColor!.resolve(disabled), AppColors.grey50);
      expect(light.foregroundColor!.resolve(disabled), colors.textGrey);
      // Outline buttons ignore the look.
      final outline = const AppButton(
        label: 'Off',
        onPressed: null,
        style: AppButtonStyle.outline,
        disabledLook: AppButtonDisabledLook.toned,
      ).buttonStyle(colors);
      expect(outline.foregroundColor!.resolve(disabled), colors.textGrey);
    });

    test('disabled looks the same in every tone', () {
      for (final tone in AppButtonTone.values) {
        final style = AppButton(
          label: 'Off',
          onPressed: null,
          tone: tone,
        ).buttonStyle(colors);
        expect(
          style.backgroundColor!.resolve({WidgetState.disabled}),
          AppColors.grey200,
        );
      }
    });
  });
}
