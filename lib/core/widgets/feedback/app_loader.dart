import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Figma "Size" axis of the DS Loader (5248:1522).
enum AppLoaderSize {
  giant(diameter: 56, strokeWidth: 6),
  large(diameter: 48, strokeWidth: 6),
  medium(diameter: 40, strokeWidth: 5),
  small(diameter: 32, strokeWidth: 4),
  tiny(diameter: 24, strokeWidth: 4);

  const AppLoaderSize({required this.diameter, required this.strokeWidth});

  final double diameter;
  final double strokeWidth;
}

/// The ClassMeet loader: an open ring with round caps (DS Loader). It spins
/// when [animate] is true; with `animate: false` it draws the static DS frame
/// (for goldens and reduced-motion layouts). Sage-500 by default (the kit's
/// blue).
class AppLoader extends StatefulWidget {
  const AppLoader({
    super.key,
    this.size = AppLoaderSize.medium,
    this.color = AppColors.sage500,
    this.animate = true,
    this.semanticLabel = 'Loading',
  });

  /// Angle where the open ring starts, in radians (9 o'clock, as in the DS).
  static const startAngle = math.pi;

  /// Length of the ring: about 300 degrees, leaving the DS gap.
  static const sweepAngle = 5 * math.pi / 3;

  /// Time for one turn.
  static const period = Duration(milliseconds: 900);

  final AppLoaderSize size;
  final Color color;
  final bool animate;
  final String semanticLabel;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppLoader.period,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(AppLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.size.diameter;
    return Semantics(
      label: widget.semanticLabel,
      child: SizedBox(
        width: d,
        height: d,
        child: RotationTransition(
          turns: _controller,
          child: CustomPaint(
            painter: _RingPainter(widget.color, widget.size.strokeWidth),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.strokeWidth);

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      AppLoader.startAngle,
      AppLoader.sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
