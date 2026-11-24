/// Spacing scale for padding and gaps, from the Figma padding variables
/// (`design/notes/tokens.md`). The Figma spacing (gap) variables use the same
/// values (none 0, sm 12, md 16), so one scale serves both.
abstract final class AppSpacing {
  /// Figma `none`: 0.
  static const double none = 0;

  /// Figma `xxs`: 4.
  static const double xxs = 4;

  /// Figma `xs`: 8.
  static const double xs = 8;

  /// Figma `sm`: 12.
  static const double sm = 12;

  /// Figma `md`: 16.
  static const double md = 16;

  /// Figma `lg`: 20.
  static const double lg = 20;

  /// Figma `xl`: 24.
  static const double xl = 24;

  /// Every step by its Figma name.
  static const Map<String, double> byFigmaName = {
    'none': none,
    'xxs': xxs,
    'xs': xs,
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
  };
}
