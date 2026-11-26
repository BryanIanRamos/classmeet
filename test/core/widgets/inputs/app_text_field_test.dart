import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpField(
  WidgetTester tester,
  Widget field, {
  double width = 350,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: field),
        ),
      ),
    ),
  );
}

BoxDecoration boxDecoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byKey(AppTextField.boxKey)).decoration
        as BoxDecoration;

Color borderColor(WidgetTester tester) =>
    (boxDecoration(tester).border! as Border).top.color;

void main() {
  group('geometry (DS Input 5248:2176)', () {
    testWidgets('large: 48 high, radius 12, 1.5 stroke, padding 12', (
      tester,
    ) async {
      await pumpField(
        tester,
        const AppTextField(placeholder: 'x', prefixIcon: AppIcons.star),
      );
      expect(tester.getSize(find.byKey(AppTextField.boxKey)).height, 48);
      expect(tester.getSize(find.byKey(AppTextField.boxKey)).width, 350);
      final deco = boxDecoration(tester);
      expect(deco.borderRadius, BorderRadius.circular(12));
      final side = (deco.border! as Border).top;
      expect(side.width, 1.5);
      expect(side.strokeAlign, BorderSide.strokeAlignInside);
      final box = tester.getRect(find.byKey(AppTextField.boxKey));
      final icon = tester.getRect(find.byIcon(AppIcons.star));
      expect(icon.left - box.left, 12);
      expect(icon.size, const Size(24, 24));
      // The text starts after the icon (24) and the gap (12).
      final field = tester.getRect(find.byType(TextField));
      expect(field.left - icon.right, 12);
    });

    testWidgets('medium: 40 high, radius 8', (tester) async {
      await pumpField(
        tester,
        const AppTextField(size: AppTextFieldSize.medium, placeholder: 'x'),
      );
      expect(tester.getSize(find.byKey(AppTextField.boxKey)).height, 40);
      expect(boxDecoration(tester).borderRadius, BorderRadius.circular(8));
    });

    testWidgets('label sits 8 above the box, helper 8 below', (tester) async {
      await pumpField(
        tester,
        const AppTextField(label: 'Label', helperText: 'Helper'),
      );
      final top = tester.getTopLeft(find.byType(AppTextField)).dy;
      final box = tester.getRect(find.byKey(AppTextField.boxKey));
      final helper = tester.getRect(find.text('Helper'));
      // Label row 16 + gap 8 (screen 96).
      expect(box.top - top, 24);
      expect(helper.top - box.bottom, 8);
      expect(helper.height, 20);
    });
  });

  group('colours per state', () {
    testWidgets('default: grey-200 border, transparent fill', (tester) async {
      await pumpField(tester, const AppTextField(placeholder: 'x'));
      expect(borderColor(tester), AppColors.grey200);
      expect(boxDecoration(tester).color, Colors.transparent);
    });

    testWidgets('hover: grey-400 border', (tester) async {
      final states = WidgetStatesController({WidgetState.hovered});
      addTearDown(states.dispose);
      await pumpField(tester, AppTextField(statesController: states));
      expect(borderColor(tester), AppColors.grey400);
    });

    testWidgets('focus: sage-500 border, from real focus', (tester) async {
      await pumpField(tester, const AppTextField(placeholder: 'x'));
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(borderColor(tester), AppColors.sage500);
    });

    testWidgets('filled style fills: default grey-50, focus sage-50', (
      tester,
    ) async {
      final states = WidgetStatesController({WidgetState.focused});
      addTearDown(states.dispose);
      await pumpField(
        tester,
        const AppTextField(style: AppTextFieldStyle.filled),
      );
      expect(boxDecoration(tester).color, AppColors.grey50);
      await pumpField(
        tester,
        AppTextField(style: AppTextFieldStyle.filled, statesController: states),
      );
      expect(boxDecoration(tester).color, AppColors.sage50);
    });

    testWidgets('error text: ember border, tinted fill, error colour text', (
      tester,
    ) async {
      await pumpField(
        tester,
        const AppTextField(
          style: AppTextFieldStyle.filled,
          helperText: 'Helper',
          errorText: 'Bad input',
        ),
      );
      expect(borderColor(tester), AppColors.ember500);
      expect(boxDecoration(tester).color, AppColors.ember50);
      expect(find.text('Bad input'), findsOneWidget);
      expect(find.text('Helper'), findsNothing);
      expect(
        tester.widget<Text>(find.text('Bad input')).style!.color,
        AppColors.ember500,
      );
    });

    testWidgets('success and warning statuses', (tester) async {
      await pumpField(
        tester,
        const AppTextField(status: AppTextFieldStatus.success),
      );
      expect(borderColor(tester), AppColors.sprout500);
      await pumpField(
        tester,
        const AppTextField(status: AppTextFieldStatus.warning),
      );
      expect(borderColor(tester), AppColors.talon500);
    });

    testWidgets('disabled: grey border and icons, ignores input', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var changed = false;
      await pumpField(
        tester,
        AppTextField(
          controller: controller,
          enabled: false,
          status: AppTextFieldStatus.error,
          prefixIcon: AppIcons.star,
          onChanged: (_) => changed = true,
        ),
      );
      expect(borderColor(tester), AppColors.grey200);
      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.star)).color,
        AppColors.grey300,
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(borderColor(tester), AppColors.grey200);
      expect(changed, isFalse);
      expect(controller.text, isEmpty);
    });

    testWidgets('accent colour tints the idle border and placeholder', (
      tester,
    ) async {
      await pumpField(
        tester,
        const AppTextField(
          placeholder: 'Enter code',
          accentColor: AppColors.talon700,
        ),
      );
      expect(borderColor(tester), AppColors.talon700);
      final hint = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!
          .hintStyle!;
      expect(hint.color, AppColors.talon700);
    });
  });

  group('behaviour', () {
    testWidgets('typing reports changes and submit', (tester) async {
      String? changed;
      String? submitted;
      await pumpField(
        tester,
        AppTextField(
          onChanged: (v) => changed = v,
          onSubmitted: (v) => submitted = v,
        ),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'hello');
    });

    testWidgets('password toggle shows and hides the text', (tester) async {
      await pumpField(tester, const AppTextField.password(placeholder: 'x'));
      bool obscured() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;
      expect(obscured(), isTrue);
      expect(find.byIcon(AppIcons.eyeOff), findsOneWidget);
      await tester.tap(find.byIcon(AppIcons.eyeOff));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.byIcon(AppIcons.eye), findsOneWidget);
      await tester.tap(find.byIcon(AppIcons.eye));
      await tester.pump();
      expect(obscured(), isTrue);
    });

    testWidgets('search: leading icon, clear button clears the text', (
      tester,
    ) async {
      String? changed;
      await pumpField(
        tester,
        AppTextField.search(
          placeholder: 'Search',
          onChanged: (v) => changed = v,
        ),
      );
      expect(find.byIcon(AppIcons.search), findsOneWidget);
      expect(find.byIcon(AppIcons.x), findsNothing);
      await tester.enterText(find.byType(TextField), 'algebra');
      await tester.pump();
      expect(find.byIcon(AppIcons.x), findsOneWidget);
      await tester.tap(find.byIcon(AppIcons.x));
      await tester.pump();
      expect(find.text('algebra'), findsNothing);
      expect(find.byIcon(AppIcons.x), findsNothing);
      expect(changed, '');
    });

    testWidgets('suffix icon taps call onSuffixTap', (tester) async {
      var taps = 0;
      await pumpField(
        tester,
        AppTextField(
          suffixIcon: AppIcons.chevronDown,
          onSuffixTap: () => taps++,
        ),
      );
      await tester.tap(find.byIcon(AppIcons.chevronDown));
      expect(taps, 1);
    });

    testWidgets('tapping the padding focuses the field', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await pumpField(tester, AppTextField(focusNode: focus));
      final box = tester.getRect(find.byKey(AppTextField.boxKey));
      await tester.tapAt(box.topLeft + const Offset(4, 4));
      await tester.pump();
      expect(focus.hasFocus, isTrue);
    });
  });

  group('layout', () {
    for (final size in AppTextFieldSize.values) {
      testWidgets('${size.name}: no overflow at 360dp with long content', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(360, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await pumpField(
          tester,
          AppTextField(
            size: size,
            label: 'A very long label that goes on and on and on and on',
            placeholder: 'A very long placeholder that cannot possibly fit',
            helperText: 'Helper text',
            prefixIcon: AppIcons.star,
            suffixIcon: AppIcons.chevronDown,
          ),
          width: 360 - 32,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('keyboard', () {
    testWidgets('autocorrect and suggestions pass through; on by default', (
      tester,
    ) async {
      await pumpField(tester, const AppTextField(placeholder: 'Text'));
      var field = tester.widget<TextField>(find.byType(TextField));
      expect((field.autocorrect, field.enableSuggestions), (true, true));

      await pumpField(
        tester,
        const AppTextField(
          placeholder: 'Code',
          autocorrect: false,
          enableSuggestions: false,
        ),
      );
      field = tester.widget<TextField>(find.byType(TextField));
      expect((field.autocorrect, field.enableSuggestions), (false, false));

      await pumpField(tester, const AppTextField.password(placeholder: 'P'));
      field = tester.widget<TextField>(find.byType(TextField));
      expect((field.autocorrect, field.enableSuggestions), (false, false));
    });

    testWidgets('the caret follows the accent colour', (tester) async {
      await pumpField(
        tester,
        const AppTextField(
          placeholder: 'Code',
          accentColor: AppColors.talon700,
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.cursorColor, AppColors.talon700);
    });
  });
}
