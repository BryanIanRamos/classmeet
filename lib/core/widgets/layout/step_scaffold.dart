import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_button.dart';
import '../feedback/app_progress_bar.dart';
import '../navigation/app_navbar_top.dart';
import 'screen_background.dart';

/// The shared shell of the onboarding steps (screens 96-99) and the
/// create-quiz steps (114-116): a top bar with back and [title], then
/// "Step [step] of [totalSteps]", a segmented progress bar, the [heading]
/// (S1) and [subheading] (B3 grey-500), the scrolling [child], and a sticky
/// bottom CTA.
///
/// The CTA ([primaryLabel], a giant expanded [AppButton]) is disabled when
/// [onPrimary] is null. An optional [secondary] widget (e.g. the outlined
/// "Edit setup" of screen 116, a large 48dp button) sits under it. The
/// content scrolls behind the CTA, which sits on a 24dp white fade (screen
/// 98's Frame 32), so a list can run to the bottom. The bar takes the top
/// safe-area inset; the CTA keeps the bottom inset. [background] defaults to
/// [ScreenBackground]; pass a plain widget to turn the pattern off.
///
/// Geometry (screen 98, 428 wide): bar 48; header, heading and [child] are
/// inset 24 (12 + 12); the CTA is inset 12, 56 tall, with 12 above and below
/// and 32 + the safe inset under it (the design shows the iPhone home
/// indicator there).
/// Where the primary button sits.
enum StepCtaLayout {
  /// Full width (inset 12) on a white band with a fade, over the scrolling
  /// list (screen 98, whose cards run to the bottom).
  sticky,

  /// Under the content, inset 24 like the content, on the screen
  /// background (screens 96, 97, 99: a spacer pushes it down). The list
  /// scrolls above it and never under it.
  inline,
}

class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.title,
    required this.step,
    required this.totalSteps,
    required this.heading,
    this.subheading,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondary,
    this.onBack,
    this.background,
    this.ctaLayout = StepCtaLayout.sticky,
  }) : assert(totalSteps > 0),
       assert(step >= 0 && step <= totalSteps);

  /// Side inset of the scrolling column (Frame 6 padding); the header,
  /// heading and [child] add [blockInset] again, 24 in total.
  static const contentInset = AppSpacing.sm;

  /// Inner side inset of each block (Frame 12/13/14 padding).
  static const blockInset = AppSpacing.sm;

  /// Side inset of the CTA.
  static const ctaInset = AppSpacing.sm;

  /// Vertical padding around the CTA.
  static const ctaPadding = AppSpacing.sm;

  /// Fade height above the CTA area.
  static const fadeHeight = AppSpacing.xl;

  /// Space under the CTA, above the safe-area inset.
  static const bottomSpacer = AppSpacing.xl + AppSpacing.xs;

  /// Gap between the CTA and the [secondary] widget.
  static const secondaryGap = AppSpacing.xs;

  /// Height of a [secondary] button (large, 48).
  static const secondaryHeight = 48.0;

  /// Height of the giant CTA button.
  static const ctaHeight = 56.0;

  final String title;
  final int step;
  final int totalSteps;
  final String heading;
  final String? subheading;
  final Widget child;
  final String primaryLabel;

  /// Null disables the CTA.
  final VoidCallback? onPrimary;
  final Widget? secondary;
  final VoidCallback? onBack;

  /// Replaces the [ScreenBackground] (e.g. a plain white box).
  final Widget? background;

  final StepCtaLayout ctaLayout;

  /// Extra space under an inline CTA (96: 80 below the button in all,
  /// 12 more than the sticky layout).
  static const inlineExtraBottom = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final footerHeight =
        fadeHeight +
        ctaPadding +
        ctaHeight +
        (secondary == null ? 0 : secondaryGap + secondaryHeight) +
        ctaPadding +
        bottomSpacer +
        bottomInset;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(child: background ?? const ScreenBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppNavbarTop(
                  title: title,
                  onBack: onBack,
                  backgroundColor: Colors.transparent,
                ),
                if (ctaLayout == StepCtaLayout.sticky)
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _scroll(colors, bottomPadding: footerHeight),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _footer(colors, bottomInset),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Expanded(child: _scroll(colors, bottomPadding: 0)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      contentInset + blockInset,
                      ctaPadding,
                      contentInset + blockInset,
                      ctaPadding +
                          bottomSpacer +
                          inlineExtraBottom +
                          bottomInset,
                    ),
                    child: _actions(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scroll(AppSemanticColors colors, {required double bottomPadding}) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: contentInset,
        right: contentInset,
        top: AppSpacing.sm,
        bottom: bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(colors),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: blockInset),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          key: const ValueKey('step-primary'),
          label: primaryLabel,
          onPressed: onPrimary,
          size: AppButtonSize.giant,
          expand: true,
        ),
        if (secondary != null) ...[
          const SizedBox(height: secondaryGap),
          secondary!,
        ],
      ],
    );
  }

  Widget _header(AppSemanticColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Step $step of $totalSteps',
                style: AppTypography.c1.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppProgressBar(
                value: step / totalSteps,
                segments: totalSteps,
                semanticLabel: 'Step $step of $totalSteps',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  heading,
                  style: AppTypography.s1.copyWith(color: colors.textPrimary),
                ),
              ),
              if (subheading != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subheading!,
                  style: AppTypography.b3.copyWith(color: AppColors.grey500),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _footer(AppSemanticColors colors, double bottomInset) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: fadeHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.fade(colors.surfaceWhite),
            ),
          ),
        ),
        ColoredBox(
          color: colors.surfaceWhite,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ctaInset,
              ctaPadding,
              ctaInset,
              ctaPadding + bottomSpacer + bottomInset,
            ),
            child: _actions(),
          ),
        ),
      ],
    );
  }
}
