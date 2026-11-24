import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/app_illustration.dart';
import '../widgets/onboarding_backdrop.dart';

/// Get started (frame 95): sign-up, Carsu sign-in or log in.
///
/// Static: it reads no repository, so there are no empty or error states.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  /// Frame width the art is laid out in; it scales down on narrower screens.
  static const _frameWidth = 428.0;

  /// The sky window (design/ref/95).
  static const _cutout = OnboardingCutout(centerY: 80, radius: 380);

  /// Height of the art area, down to the headline (design/ref/95).
  static const _sceneHeight = 470.0;

  /// The sky art is wider than the frame; its offset from the frame's left
  /// edge and top (design/ref/95).
  static const _skyLeft = -92.0;
  static const _skyTop = 70.0;

  /// Position of the winking owl (design/ref/95).
  static const _owlLeft = 33.5;
  static const _owlTop = 145.0;

  /// Space under the log-in line, less the system inset (Figma 61).
  static const _bottomGap = 48.0;

  /// Height of everything under the scene, to shrink the scene on short
  /// screens.
  static const _belowScene = 400.0;

  /// Height of the "Or" divider row (Figma 24).
  static const _dividerHeight = 24.0;

  /// Gap between the stacked actions (Figma 10).
  static const _actionGap = 10.0;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final TapGestureRecognizer _logIn = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.login);

  @override
  void dispose() {
    _logIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const captionStyle = AppTypography.c1;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            math.min(constraints.maxWidth / WelcomeScreen._frameWidth, 1.0),
            math.max(
              0.35,
              (constraints.maxHeight - WelcomeScreen._belowScene) /
                  WelcomeScreen._sceneHeight,
            ),
          );
          return OnboardingBackdrop(
            color: AppColors.talon100,
            glowCenterY: 0,
            cutout: WelcomeScreen._cutout.scaledBy(scale),
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        SizedBox(
                          width: WelcomeScreen._frameWidth * scale,
                          height: WelcomeScreen._sceneHeight * scale,
                          child: const FittedBox(
                            fit: BoxFit.fill,
                            child: SizedBox(
                              width: WelcomeScreen._frameWidth,
                              height: WelcomeScreen._sceneHeight,
                              child: _Scene(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            'Your learning adventure starts here!',
                            textAlign: TextAlign.center,
                            style: AppTypography.h3ExtraBold.copyWith(
                              color: AppColors.sage700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.sm,
                            AppSpacing.xl,
                            WelcomeScreen._bottomGap,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppButton(
                                label: 'Get started',
                                size: AppButtonSize.giant,
                                expand: true,
                                onPressed: () => context.push(Routes.signUp),
                              ),
                              const SizedBox(height: WelcomeScreen._actionGap),
                              const _OrDivider(),
                              const SizedBox(height: WelcomeScreen._actionGap),
                              AppButton(
                                label: 'Continue with Carsu',
                                size: AppButtonSize.giant,
                                style: AppButtonStyle.outline,
                                tone: AppButtonTone.plume,
                                expand: true,
                                onPressed: () =>
                                    context.push(Routes.carsuSignIn),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: captionStyle.copyWith(
                                      color: context.colors.textPrimary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Log In',
                                        recognizer: _logIn,
                                        style: captionStyle.copyWith(
                                          color: context.colors.textLinks,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene();

  @override
  Widget build(BuildContext context) {
    return const OnboardingCutoutClip(
      cutout: WelcomeScreen._cutout,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: WelcomeScreen._skyLeft,
            top: WelcomeScreen._skyTop,
            child: AppIllustration(AppImages.welcomeSky),
          ),
          Positioned(
            left: WelcomeScreen._owlLeft,
            top: WelcomeScreen._owlTop,
            child: AppIllustration(AppImages.welcomeOwl),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(color: AppColors.grey300, height: 1, thickness: 1),
    );
    return SizedBox(
      height: WelcomeScreen._dividerHeight,
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
