import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/layout/app_sheet.dart';
import '../../widgets/layout/screen_background.dart';
import '../../widgets/layout/step_scaffold.dart';

Widget _title(String text) => Padding(
  padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
  child: Text(text, style: AppTypography.s2),
);

/// Height of the framed examples.
const _frameHeight = 520.0;

/// [ScreenBackground] with and without the doodle pattern.
class ScreenBackgroundMatrix extends StatelessWidget {
  const ScreenBackgroundMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    Widget frame(bool pattern) => SizedBox(
      width: 214,
      height: 436,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
          child: ScreenBackground(
            showPattern: pattern,
            child: Center(
              child: Text(
                pattern ? 'Pattern 5%' : 'Plain',
                style: AppTypography.b2,
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        frame(true),
        const SizedBox(width: AppSpacing.md),
        frame(false),
      ],
    );
  }
}

/// [AppSheet] panels shown inline: a plain one, one with a header and
/// footer, and a tall one that scrolls.
class AppSheetMatrix extends StatelessWidget {
  const AppSheetMatrix({super.key});

  static const _width = 428.0;

  Widget _scrim(Widget sheet, {double height = 300}) => SizedBox(
    width: _width,
    height: height,
    child: ColoredBox(
      color: AppColors.black30,
      child: Align(alignment: Alignment.bottomCenter, child: sheet),
    ),
  );

  Widget _text(int lines) => Text(
    List.filled(lines, 'A short line of sheet content.').join('\n'),
    style: AppTypography.b3.copyWith(color: AppColors.grey500),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Grabber only'),
        _scrim(AppSheet(child: _text(3))),
        _title('Title, close and footer'),
        _scrim(
          AppSheet(
            title: 'Explain simply',
            onClose: () {},
            footer: AppButton(
              label: 'Save to notes',
              onPressed: () {},
              expand: true,
            ),
            child: _text(3),
          ),
          height: 360,
        ),
        _title('Tall content scrolls (footer stays)'),
        _scrim(
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: AppSheet(
              footer: AppButton(label: 'Done', onPressed: () {}, expand: true),
              child: _text(30),
            ),
          ),
          height: 320,
        ),
      ],
    );
  }
}

/// Placeholder rows for the [StepScaffold] example (screen 98's list).
class _PlaceholderList extends StatelessWidget {
  const _PlaceholderList();

  @override
  Widget build(BuildContext context) {
    const selected = {0, 4};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Preferred study methods', style: AppTypography.b2),
              Text(
                '2 of 3 selected',
                style: AppTypography.c1.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
        ),
        for (var i = 0; i < 6; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: SizedBox(
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected.contains(i)
                      ? AppColors.sage500
                      : AppColors.sage50,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.md),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A [StepScaffold] in a phone-sized frame (screen 98, "Step 3 of 4").
class StepScaffoldExample extends StatelessWidget {
  const StepScaffoldExample({
    super.key,
    this.width = 428,
    this.height = _frameHeight * 1.5,
    this.enabled = true,
    this.secondary,
  });

  final double width;
  final double height;
  final bool enabled;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: StepScaffold(
        title: 'Your learning preferences',
        step: 3,
        totalSteps: 4,
        heading: 'How do you like to study?',
        subheading:
            "Choose the methods you enjoy. We'll tailor your study sessions "
            'to you.',
        primaryLabel: 'Continue',
        onPrimary: enabled ? () {} : null,
        onBack: () {},
        secondary: secondary,
        child: const _PlaceholderList(),
      ),
    );
  }
}

/// Matrix of [StepScaffold]: enabled CTA, disabled CTA and a secondary
/// button.
class StepScaffoldMatrix extends StatelessWidget {
  const StepScaffoldMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _title('Default'),
        const StepScaffoldExample(),
        _title('CTA disabled'),
        const StepScaffoldExample(enabled: false),
        _title('With secondary (screen 116)'),
        StepScaffoldExample(
          secondary: AppButton(
            label: 'Edit setup',
            onPressed: () {},
            style: AppButtonStyle.outline,
            expand: true,
          ),
        ),
      ],
    );
  }
}
