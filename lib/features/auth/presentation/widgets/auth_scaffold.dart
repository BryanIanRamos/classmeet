import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/app_illustration.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';

/// The shared look of the auth screens: Create account (3.1/3.2), and by
/// analogy Log in and Forgot password (GAP-01/02).
///
/// From the back: the doodle backdrop, a soft `sage300` glow (Figma
/// "Ellipse 5"), the `sage50` panel with 32 top corners, the top bar with
/// [title] (under the owl in 3.1, as in the design) and Ollie peeking over
/// the panel. The panel scrolls: [caption], the [fields], an optional
/// [alert], the primary button, and, when [showCarsu] is set, the "Or"
/// divider, the school-account note and "Continue with Carsu". A [footer]
/// sits at the bottom.
///
/// Frame 3.2 is the focused state of 3.1 (its first field focused), so one
/// layout serves both; 3.1's sage backdrop is used.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.caption,
    required this.fields,
    required this.primaryLabel,
    required this.onPrimary,
    this.alert,
    this.showCarsu = true,
    this.onCarsu,
    this.footer,
    this.onBack,
  });

  /// Top of the panel in the 428 × 870 frame (Frame 6 sits 151 down), and
  /// its least distance under the system inset (151 - 62).
  static const panelTop = 151.0;
  static const panelTopBelowInset = 89.0;

  /// Height of the owl art over the panel's top edge: it ends 24 below it.
  static const owlOverlap = 133.0;

  /// Distance the glow reaches below the top edge, and its strength at the
  /// panel (the blurred Figma ellipse, approximated by a fade).
  static const glowHeight = 200.0;
  static const glowAlpha = 0.55;

  /// Gap between the stacked actions (Figma 10).
  static const actionGap = 10.0;

  /// Space between the last field and the primary button (spacer 32 + 12
  /// padding on each side).
  static const fieldsToButton = 56.0;

  /// Idle border and placeholder tint of the fields in 3.1 (sage-500).
  static const fieldAccent = AppColors.sage500;

  /// Height of the "Or" divider row (Figma 24).
  static const dividerHeight = 24.0;

  /// Space under the panel content, above the system inset.
  static const bottomGap = AppSpacing.md;

  final String title;
  final String caption;
  final List<Widget> fields;
  final String primaryLabel;

  /// Null disables the primary button.
  final VoidCallback? onPrimary;

  /// Shown between the fields and the primary button.
  final Widget? alert;
  final bool showCarsu;
  final VoidCallback? onCarsu;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context);
    final fromInset = inset.top + panelTopBelowInset;
    final top = panelTop > fromInset ? panelTop : fromInset;
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ScreenBackground(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: glowHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.sage300.withValues(alpha: 0),
                    AppColors.sage300.withValues(alpha: glowAlpha),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: top,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.sage50,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xxl),
                ),
              ),
              child: _panel(context, inset),
            ),
          ),
          Positioned(
            top: inset.top,
            left: 0,
            right: 0,
            child: AppNavbarTop(
              title: title,
              onBack: onBack,
              backgroundColor: Colors.transparent,
            ),
          ),
          Positioned(
            top: top - owlOverlap,
            left: 0,
            right: 0,
            child: const IgnorePointer(
              child: Center(child: AppIllustration(AppImages.signupOwl)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context, EdgeInsets inset) {
    final colors = context.colors;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              bottomGap + inset.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: AppTypography.b3.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < fields.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  fields[i],
                ],
                const SizedBox(height: fieldsToButton),
                if (alert case final alert?) ...[
                  alert,
                  const SizedBox(height: AppSpacing.md),
                ],
                AppButton(
                  label: primaryLabel,
                  size: AppButtonSize.giant,
                  expand: true,
                  onPressed: onPrimary,
                ),
                if (showCarsu) ...[
                  const SizedBox(height: actionGap),
                  const AuthOrDivider(),
                  const SizedBox(height: actionGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'Use your school account to easily find your peers in '
                      'seconds.',
                      textAlign: TextAlign.center,
                      style: AppTypography.c1.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: actionGap),
                  AppButton(
                    label: 'Continue with Carsu',
                    size: AppButtonSize.giant,
                    style: AppButtonStyle.outline,
                    expand: true,
                    onPressed: onCarsu,
                  ),
                ],
                const Spacer(),
                if (footer case final footer?)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The "Or" divider of screens 95 and 3.1: a line, "Or", a line.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(color: AppColors.sage500, height: 1, thickness: 1),
    );
    return SizedBox(
      height: AuthScaffold.dividerHeight,
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Or',
              style: AppTypography.c1.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}
