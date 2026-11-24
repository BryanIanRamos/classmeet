import 'dart:typed_data';

import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/display/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpAvatar(WidgetTester tester, Widget avatar) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: avatar)),
    ),
  );
}

/// A 1x1 transparent PNG.
final _pixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  test('diameters and dots match the DS component', () {
    expect(
      {
        for (final s in AppAvatarSize.values)
          s.name: (s.diameter, s.dot, s.dotBorder),
      },
      {
        'tiny': (24, 8, 1.5),
        'small': (32, 10, 1.5),
        'medium': (40, 12, 2),
        'large': (48, 12, 2),
        'giant': (56, 16, 2.5),
        'xlGiant': (64, 16, 2.5),
        'xxlGiant': (80, 20, 3),
        'xxxlGiant': (96, 24, 3),
      },
    );
  });

  for (final size in AppAvatarSize.values) {
    testWidgets('${size.name}: letter, icon and image are square', (
      tester,
    ) async {
      for (final avatar in [
        AppAvatar.letter(letter: 'a', size: size),
        AppAvatar.icon(size: size),
        AppAvatar.image(imageProvider: MemoryImage(_pixel), size: size),
      ]) {
        await pumpAvatar(tester, avatar);
        expect(
          tester.getSize(find.byType(AppAvatar)),
          Size.square(size.diameter),
        );
      }
    });
  }

  group('types', () {
    testWidgets('letter shows the upper-cased first character', (tester) async {
      await pumpAvatar(tester, const AppAvatar.letter(letter: 'joshua'));
      expect(find.text('J'), findsOneWidget);
      final text = tester.widget<Text>(find.text('J'));
      expect(text.style!.color, Colors.white);
      expect(text.style!.fontSize, AppAvatarSize.small.letterStyle.fontSize);
    });

    testWidgets('letter and icon fill with the background colour', (
      tester,
    ) async {
      await pumpAvatar(
        tester,
        const AppAvatar.letter(
          letter: 'B',
          backgroundColor: AppColors.sprout300,
        ),
      );
      expect(
        tester
            .widget<ColoredBox>(
              find.descendant(
                of: find.byType(AppAvatar),
                matching: find.byType(ColoredBox),
              ),
            )
            .color,
        AppColors.sprout300,
      );
      await pumpAvatar(tester, const AppAvatar.icon());
      expect(
        tester
            .widget<ColoredBox>(
              find.descendant(
                of: find.byType(AppAvatar),
                matching: find.byType(ColoredBox),
              ),
            )
            .color,
        AppColors.sage500,
      );
    });

    testWidgets('icon is half the diameter and white', (tester) async {
      await pumpAvatar(
        tester,
        const AppAvatar.icon(size: AppAvatarSize.xxlGiant),
      );
      expect(tester.getSize(find.byIcon(AppIcons.smile)), const Size(40, 40));
      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.smile)).color,
        Colors.white,
      );
    });

    testWidgets('image is clipped to a circle', (tester) async {
      await pumpAvatar(
        tester,
        AppAvatar.image(imageProvider: MemoryImage(_pixel)),
      );
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('status dot', () {
    testWidgets('hidden by default', (tester) async {
      await pumpAvatar(tester, const AppAvatar.letter(letter: 'A'));
      expect(find.byKey(const ValueKey('avatar-dot')), findsNothing);
    });

    for (final size in AppAvatarSize.values) {
      testWidgets('${size.name}: green dot at the bottom right', (
        tester,
      ) async {
        await pumpAvatar(
          tester,
          AppAvatar.letter(letter: 'A', size: size, showStatus: true),
        );
        final dot = find.byKey(const ValueKey('avatar-dot'));
        expect(tester.getSize(dot), Size.square(size.dot));
        expect(
          tester.getBottomRight(dot),
          tester.getBottomRight(find.byType(AppAvatar)),
        );
        final decoration =
            tester.widget<Container>(dot).decoration! as BoxDecoration;
        expect(decoration.color, AppColors.sprout500);
        expect(
          decoration.border,
          Border.all(color: AppColors.white, width: size.dotBorder),
        );
      });
    }
  });

  testWidgets('no overflow at 360', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpAvatar(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar.letter(
            letter: 'A',
            size: AppAvatarSize.xxxlGiant,
            showStatus: true,
          ),
          AppAvatar.icon(size: AppAvatarSize.xxlGiant),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
