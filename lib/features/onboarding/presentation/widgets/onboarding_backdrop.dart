import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/layout/screen_background.dart';

/// A circle in design units (the 428-wide Figma frame); it scales with the
/// screen width.
class OnboardingCutout {
  const OnboardingCutout({
    required this.centerY,
    required this.radius,
    this.scale = 1,
  });

  /// Frame width the numbers are given in.
  static const frameWidth = 428.0;

  final double centerY;
  final double radius;

  /// Factor from design units to dp.
  final double scale;

  OnboardingCutout scaledBy(double factor) =>
      OnboardingCutout(centerY: centerY, radius: radius, scale: scale * factor);

  /// The circle on a screen [width] wide, centred horizontally.
  Rect rect(double width) {
    final k = scale;
    return Rect.fromCircle(
      center: Offset(width / 2, centerY * k),
      radius: radius * k,
    );
  }
}

/// Warm backdrop shared by the splash (94) and the welcome choice (95).
///
/// From the back: the [color] frame fill, a big soft `talon300` glow (Figma
/// "Ellipse 5", 914 wide, blur 127; here a radial fade), then the white
/// "Subtract" layer with the doodle pattern. With a [cutout] the white layer
/// has a round hole, where the scene's art shows.
class OnboardingBackdrop extends StatelessWidget {
  const OnboardingBackdrop({
    super.key,
    required this.color,
    required this.glowCenterY,
    this.cutout,
    required this.child,
  });

  /// Diameter of the glow ellipse (Figma 914).
  static const glowSize = 914.0;

  /// Frame fill: `talon50` (94) or `talon100` (95).
  final Color color;

  /// Distance from the top edge to the glow's centre.
  final double glowCenterY;

  /// A round hole in the white layer, where the scene's art shows.
  final OnboardingCutout? cutout;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glow = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppColors.talon300, AppColors.talon300.withValues(alpha: 0)],
          stops: const [0.25, 1],
        ),
      ),
    );
    return ColoredBox(
      color: color,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: glowCenterY - glowSize / 2,
            left: 0,
            right: 0,
            height: glowSize,
            child: OverflowBox(
              maxWidth: glowSize,
              child: SizedBox(width: glowSize, height: glowSize, child: glow),
            ),
          ),
          Positioned.fill(
            child: ClipPath(
              clipper: cutout == null
                  ? null
                  : _CutoutClipper(cutout!, invert: true),
              child: const ScreenBackground(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Clips [child] to the [cutout] circle.
class OnboardingCutoutClip extends StatelessWidget {
  const OnboardingCutoutClip({
    super.key,
    required this.cutout,
    required this.child,
  });

  final OnboardingCutout cutout;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ClipPath(clipper: _CutoutClipper(cutout), child: child);
}

class _CutoutClipper extends CustomClipper<Path> {
  const _CutoutClipper(this.cutout, {this.invert = false});

  final OnboardingCutout cutout;
  final bool invert;

  @override
  Path getClip(Size size) {
    final circle = Path()..addOval(cutout.rect(size.width));
    if (!invert) return circle;
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      circle,
    );
  }

  @override
  bool shouldReclip(_CutoutClipper old) =>
      old.cutout.centerY != cutout.centerY ||
      old.cutout.radius != cutout.radius ||
      old.cutout.scale != cutout.scale ||
      old.invert != invert;
}
