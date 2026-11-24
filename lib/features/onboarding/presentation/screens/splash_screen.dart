import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/app_illustration.dart';
import '../widgets/onboarding_backdrop.dart';

/// Welcome (frame 94): the classroom scene, the pitch and "Get started".
///
/// Static: it reads no repository, so there are no empty or error states.
/// The scene is laid out in the 428-wide Figma frame and scales down on
/// narrower or shorter screens; the content scrolls when still too tall.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Frame width the art is laid out in.
  static const _frameWidth = 428.0;

  /// The classroom's box (Figma 426 circle).
  static const _sceneHeight = 428.0;

  /// The classroom's round window: a circle meeting the frame's sides at
  /// y 345 and its bottom at 428 (design/ref/94).
  static const _cutout = OnboardingCutout(centerY: 111, radius: 317);

  /// Gap between the scene and the headline (Figma 55, as drawn 65).
  static const _sceneGap = 65.0;

  /// Space under the button (Figma: 98 up to the frame bottom, less the
  /// system inset).
  static const _bottomGap = 73.0;

  /// Height of everything under the scene, to shrink the scene on short
  /// screens.
  static const _belowScene = 330.0;

  // Positions of the classroom, board and owl in the scene (design/ref/94).
  static const _classroomTop = 8.0;
  static const _boardLeft = 44.0;
  static const _boardTop = 48.0;
  static const _owlLeft = 77.0;
  static const _owlTop = 72.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            math.min(constraints.maxWidth / _frameWidth, 1.0),
            math.max(
              0.35,
              (constraints.maxHeight - _belowScene) / _sceneHeight,
            ),
          );
          return OnboardingBackdrop(
            color: AppColors.talon50,
            glowCenterY: _sceneHeight * scale,
            cutout: _cutout.scaledBy(scale),
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        SizedBox(
                          width: _frameWidth * scale,
                          height: _sceneHeight * scale,
                          child: const FittedBox(
                            fit: BoxFit.fill,
                            child: SizedBox(
                              width: _frameWidth,
                              height: _sceneHeight,
                              child: _Scene(),
                            ),
                          ),
                        ),
                        SizedBox(height: _sceneGap * scale),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: _Pitch(),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.xl,
                            _bottomGap,
                          ),
                          child: AppButton(
                            label: 'Get started',
                            size: AppButtonSize.giant,
                            expand: true,
                            onPressed: () => context.push(Routes.welcome),
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
      cutout: SplashScreen._cutout,
      child: Stack(
        children: [
          Positioned(
            top: SplashScreen._classroomTop,
            child: AppIllustration(AppImages.splashClassroom),
          ),
          Positioned(
            left: SplashScreen._boardLeft,
            top: SplashScreen._boardTop,
            child: AppIllustration(AppImages.splashBoard),
          ),
          Positioned(
            left: SplashScreen._owlLeft,
            top: SplashScreen._owlTop,
            child: AppIllustration(AppImages.splashOwlTeacher),
          ),
        ],
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'A little wiser every day.',
          textAlign: TextAlign.center,
          style: AppTypography.h3ExtraBold.copyWith(color: AppColors.sage700),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'From class notes to quick quizzes, make every lesson a little '
          'easier to master.',
          textAlign: TextAlign.center,
          style: AppTypography.b1.copyWith(color: AppColors.grey900),
        ),
      ],
    );
  }
}
