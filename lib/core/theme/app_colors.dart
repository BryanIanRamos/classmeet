import 'dart:ui' show Color;

/// The raw ClassMeet palette, from the Figma colour variables
/// (`design/notes/tokens.md`).
///
/// Widgets should prefer the semantic roles in `AppSemanticColors`
/// (`context.colors`). Use a palette colour directly only where the design
/// uses one without a role, such as card fills and borders.
abstract final class AppColors {
  // Sage: primary.
  static const sage50 = Color(0xFFEDF5F4);
  static const sage100 = Color(0xFFD9EAE8);
  static const sage300 = Color(0xFF94BDB8);
  static const sage500 = Color(0xFF42807F);
  static const sage700 = Color(0xFF2B5756);
  static const sage900 = Color(0xFF173332);

  // Plume: secondary and accent.
  static const plume50 = Color(0xFFE6F1F4);
  static const plume100 = Color(0xFFC5E0E6);
  static const plume300 = Color(0xFF6F9DA8);
  static const plume500 = Color(0xFF084457);

  // Talon: credits and warnings.
  static const talon50 = Color(0xFFFFFAED);
  static const talon100 = Color(0xFFFFF2D6);
  static const talon300 = Color(0xFFFFD77F);
  static const talon500 = Color(0xFFFFC457);
  static const talon700 = Color(0xFFB77B21);
  static const talon900 = Color(0xFF5D3D15);

  // Ember: streaks and alerts.
  static const ember50 = Color(0xFFFFF2EF);
  static const ember100 = Color(0xFFFFDCD5);
  static const ember300 = Color(0xFFFF9D8B);
  static const ember500 = Color(0xFFFF5A3B);
  static const ember700 = Color(0xFFCC4830);

  // Sprout: success.
  static const sprout50 = Color(0xFFECF9F1);
  static const sprout100 = Color(0xFFD3F0DE);
  static const sprout300 = Color(0xFF8BD0A5);
  static const sprout500 = Color(0xFF45B978);
  static const sprout700 = Color(0xFF35935E);
  static const sprout900 = Color(0xFF287247);

  // Sky: info.
  static const sky50 = Color(0xFFF0F7F9);
  static const sky100 = Color(0xFFD9E6F0);
  static const sky300 = Color(0xFFA5C6D5);
  static const sky500 = Color(0xFF74A7BB);
  static const sky700 = Color(0xFF598AA3);
  static const sky900 = Color(0xFF466382);

  // Grey.
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EA);
  static const grey300 = Color(0xFFD2D5DB);
  static const grey400 = Color(0xFF9EA2AE);
  static const grey500 = Color(0xFF6D717F);
  static const grey600 = Color(0xFF4D5461);
  static const grey900 = Color(0xFF131927);

  // Base colours and overlays.
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const black10 = Color(0x1A000000);
  static const black30 = Color(0x4D000000);
  static const black50 = Color(0x80000000);
  static const white10 = Color(0x1AFFFFFF);

  /// Every palette family by Figma name, then shade. Used by the token
  /// gallery and the tests.
  static const Map<String, Map<int, Color>> families = {
    'Sage': {
      50: sage50,
      100: sage100,
      300: sage300,
      500: sage500,
      700: sage700,
      900: sage900,
    },
    'Plume': {50: plume50, 100: plume100, 300: plume300, 500: plume500},
    'Talon': {
      50: talon50,
      100: talon100,
      300: talon300,
      500: talon500,
      700: talon700,
      900: talon900,
    },
    'Ember': {
      50: ember50,
      100: ember100,
      300: ember300,
      500: ember500,
      700: ember700,
    },
    'Sprout': {
      50: sprout50,
      100: sprout100,
      300: sprout300,
      500: sprout500,
      700: sprout700,
      900: sprout900,
    },
    'Sky': {
      50: sky50,
      100: sky100,
      300: sky300,
      500: sky500,
      700: sky700,
      900: sky900,
    },
    'Grey': {
      50: grey50,
      100: grey100,
      200: grey200,
      300: grey300,
      400: grey400,
      500: grey500,
      600: grey600,
      900: grey900,
    },
  };

  /// Base colours and overlays by Figma name.
  static const Map<String, Color> overlays = {
    'White 100%': white,
    'Labels/Primary': black,
    'Black 10%': black10,
    'Black 30%': black30,
    'Black 50%': black50,
    'White 10%': white10,
  };
}
