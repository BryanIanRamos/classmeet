import 'package:flutter/painting.dart';

/// Gradients used on the screens.
abstract final class AppGradients {
  /// Figma "Surface Fade": a tint fading in from transparent, used behind
  /// card art and sheet edges (Sage, Sprout, Talon, Plume and white fades in
  /// the Home, Create and Play sections). Top to bottom unless the design
  /// runs it sideways.
  static LinearGradient fade(
    Color color, {
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) => LinearGradient(
    begin: begin,
    end: end,
    colors: [color.withValues(alpha: 0), color],
  );
}
