/// Corner radius scale, from the Figma corner-radius variables
/// (`design/notes/tokens.md`).
///
/// Use with `BorderRadius.all(Radius.circular(AppRadii.md))`, which stays
/// const.
abstract final class AppRadii {
  /// Figma `none`: 0.
  static const double none = 0;

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

  /// Figma `xxl`: 32.
  static const double xxl = 32;

  /// Figma `5xl`: 64, used for pills such as the bottom-nav selector.
  static const double xl5 = 64;

  /// Every step by its Figma name.
  static const Map<String, double> byFigmaName = {
    'none': none,
    'xs': xs,
    'sm': sm,
    'md': md,
    'lg': lg,
    'xl': xl,
    'xxl': xxl,
    '5xl': xl5,
  };
}
