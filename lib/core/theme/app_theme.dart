import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_semantic_colors.dart';
import 'app_typography.dart';

/// The app's [ThemeData], built from the design tokens.
///
/// ClassMeet screens use the App* widgets and the tokens directly. The
/// Material [ColorScheme] and [TextTheme] below make stock Material widgets
/// and plain `Text` fall back to design values instead of Material defaults.
abstract final class AppTheme {
  /// The light theme, the only one designed so far.
  static final ThemeData light = _build();

  static ThemeData _build() {
    const colors = AppSemanticColors.light;
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.sage500,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.sage100,
      onPrimaryContainer: AppColors.sage900,
      secondary: AppColors.plume500,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.plume100,
      onSecondaryContainer: AppColors.plume500,
      error: AppColors.ember500,
      onError: AppColors.white,
      errorContainer: AppColors.ember100,
      onErrorContainer: AppColors.ember700,
      surface: AppColors.white,
      onSurface: AppColors.grey900,
      onSurfaceVariant: AppColors.grey500,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.grey50,
      surfaceContainer: AppColors.grey50,
      surfaceContainerHigh: AppColors.grey100,
      surfaceContainerHighest: AppColors.grey200,
      outline: AppColors.grey300,
      outlineVariant: AppColors.grey200,
      shadow: AppColors.black,
      scrim: AppColors.black50,
      inverseSurface: AppColors.grey900,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.sage300,
      // Keep raised surfaces pure white, as in the design.
      surfaceTint: Colors.transparent,
    );

    final textTheme = const TextTheme(
      displayLarge: AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall: AppTypography.h3,
      headlineLarge: AppTypography.h3,
      headlineMedium: AppTypography.h5,
      headlineSmall: AppTypography.h5,
      titleLarge: AppTypography.s1,
      titleMedium: AppTypography.s2,
      titleSmall: AppTypography.b4,
      bodyLarge: AppTypography.b1,
      bodyMedium: AppTypography.b3,
      bodySmall: AppTypography.c1,
      labelLarge: AppTypography.buttonMedium,
      labelMedium: AppTypography.c2,
      labelSmall: AppTypography.c3,
    ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);

    return ThemeData(
      colorScheme: scheme,
      fontFamily: AppTypography.jakarta,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.surfaceWhite,
      extensions: const [colors],
    );
  }
}
