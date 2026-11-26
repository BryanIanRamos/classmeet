import 'package:flutter/material.dart';

import '../../assets/app_images.dart';
import '../../theme/app_semantic_colors.dart';

/// The screen backdrop of ClassMeet: a white fill with the study-doodle
/// pattern over it (every screen frame, e.g. `design/ref/home/8_*.png`).
///
/// Figma fills the frame with the image (`FILL`, so [BoxFit.cover]) at 5 %
/// opacity, with exposure -1, contrast -0.3, saturation -1 and highlights and
/// shadows -1. That is a darkened greyscale line drawing; here it is a
/// greyscale [ColorFilter] that also halves the brightness. The exported
/// image already carries Figma's 5 % in its alpha (at most 13/255, a test
/// checks it), so it is drawn as is: fading it again made the doodle all but
/// invisible (a darkest pixel of 254 against the frames' 243). Set
/// [showPattern] to false for a plain white surface. The image is decoded no
/// wider than the screen needs (`cacheWidth`).
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({
    super.key,
    this.child,
    this.showPattern = true,
    this.color,
  });

  /// Highest alpha in the exported pattern: Figma's 5 % fill opacity, baked
  /// into the image (13/255). A test fails if a re-export drops it.
  static const maxPatternAlpha = 13;

  /// Brightness of the greyscale pattern (stand-in for the exposure and
  /// shadows adjustments).
  static const _darken = 0.5;

  static const _filter = ColorFilter.matrix(<double>[
    0.2126 * _darken, 0.7152 * _darken, 0.0722 * _darken, 0, 0, //
    0.2126 * _darken, 0.7152 * _darken, 0.0722 * _darken, 0, 0, //
    0.2126 * _darken, 0.7152 * _darken, 0.0722 * _darken, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  final Widget? child;

  /// Draw the doodle pattern. False gives the plain white surface.
  final bool showPattern;

  /// Base fill; defaults to the white surface.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? context.colors.surfaceWhite;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ColoredBox(
      color: fill,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (showPattern)
            Positioned.fill(
              child: ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.hasBoundedWidth
                        ? (constraints.maxWidth * dpr).ceil()
                        : null;
                    return ColorFiltered(
                      colorFilter: _filter,
                      child: Image.asset(
                        AppImages.bgPattern.path,
                        key: const ValueKey('screen-background-pattern'),
                        fit: BoxFit.cover,
                        cacheWidth: width,
                        gaplessPlayback: true,
                      ),
                    );
                  },
                ),
              ),
            ),
          ?child,
        ],
      ),
    );
  }
}
