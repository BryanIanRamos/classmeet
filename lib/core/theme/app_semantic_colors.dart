import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colour roles from the Figma variables (text, icon and surface).
///
/// Read them with `context.colors`, e.g. `context.colors.textPrimary`.
/// [byFigmaName] maps each Figma variable name to its colour.
@immutable
final class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textGrey,
    required this.textLightGrey,
    required this.textDisabled,
    required this.textPrimaryWhite,
    required this.textSecondaryWhite,
    required this.textAccent,
    required this.textSecondaryAccent,
    required this.textLinks,
    required this.textSuccess,
    required this.textWarning,
    required this.iconBlack,
    required this.iconGrey,
    required this.iconLightGrey,
    required this.iconDisabled,
    required this.iconWhite,
    required this.iconAccent,
    required this.iconSecondaryAccent,
    required this.iconSuccess,
    required this.iconWarning,
    required this.surfaceWhite,
    required this.surfaceLightGrey,
  });

  /// The light theme, the only one designed so far.
  static const light = AppSemanticColors(
    textPrimary: AppColors.grey900,
    textSecondary: AppColors.grey500,
    textGrey: AppColors.grey400,
    textLightGrey: AppColors.grey300,
    textDisabled: AppColors.grey200,
    textPrimaryWhite: AppColors.white,
    textSecondaryWhite: Color(0x99FFFFFF),
    textAccent: AppColors.plume500,
    textSecondaryAccent: AppColors.sage500,
    textLinks: AppColors.plume300,
    textSuccess: AppColors.sprout500,
    textWarning: AppColors.talon500,
    iconBlack: AppColors.grey900,
    iconGrey: AppColors.grey400,
    iconLightGrey: AppColors.grey300,
    iconDisabled: AppColors.grey200,
    iconWhite: AppColors.white,
    iconAccent: AppColors.plume500,
    iconSecondaryAccent: AppColors.sage500,
    iconSuccess: AppColors.sprout500,
    iconWarning: AppColors.talon500,
    surfaceWhite: AppColors.white,
    surfaceLightGrey: AppColors.grey50,
  );

  /// Figma `text-primary-black`.
  final Color textPrimary;

  /// Figma `text-secondary-dark-grey`.
  final Color textSecondary;

  /// Figma `text-grey`.
  final Color textGrey;

  /// Figma `text-light-grey`.
  final Color textLightGrey;

  /// Figma `text-disabled`.
  final Color textDisabled;

  /// Figma `text-primary-white`.
  final Color textPrimaryWhite;

  /// Figma `text-secondary-white` (white at 60%).
  final Color textSecondaryWhite;

  /// Figma `text-accent`.
  final Color textAccent;

  /// Figma `text-secondary-accent`.
  final Color textSecondaryAccent;

  /// Figma `text-links`.
  final Color textLinks;

  /// Figma `text-success`.
  final Color textSuccess;

  /// Figma `text-warning`.
  final Color textWarning;

  /// Figma `icon-black`.
  final Color iconBlack;

  /// Figma `icon-grey`.
  final Color iconGrey;

  /// Figma `icon-light-grey`.
  final Color iconLightGrey;

  /// Figma `icon-disabled`.
  final Color iconDisabled;

  /// Figma `icon-white`.
  final Color iconWhite;

  /// Figma `icon-accent`.
  final Color iconAccent;

  /// Figma `icon-secondary-accent`.
  final Color iconSecondaryAccent;

  /// Figma `icon-success`.
  final Color iconSuccess;

  /// Figma `icon-warning`.
  final Color iconWarning;

  /// Figma `surface-white`.
  final Color surfaceWhite;

  /// Figma `surface-light-grey`.
  final Color surfaceLightGrey;

  /// Every role by its Figma variable name.
  Map<String, Color> get byFigmaName => {
    'text-primary-black': textPrimary,
    'text-secondary-dark-grey': textSecondary,
    'text-grey': textGrey,
    'text-light-grey': textLightGrey,
    'text-disabled': textDisabled,
    'text-primary-white': textPrimaryWhite,
    'text-secondary-white': textSecondaryWhite,
    'text-accent': textAccent,
    'text-secondary-accent': textSecondaryAccent,
    'text-links': textLinks,
    'text-success': textSuccess,
    'text-warning': textWarning,
    'icon-black': iconBlack,
    'icon-grey': iconGrey,
    'icon-light-grey': iconLightGrey,
    'icon-disabled': iconDisabled,
    'icon-white': iconWhite,
    'icon-accent': iconAccent,
    'icon-secondary-accent': iconSecondaryAccent,
    'icon-success': iconSuccess,
    'icon-warning': iconWarning,
    'surface-white': surfaceWhite,
    'surface-light-grey': surfaceLightGrey,
  };

  @override
  AppSemanticColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textGrey,
    Color? textLightGrey,
    Color? textDisabled,
    Color? textPrimaryWhite,
    Color? textSecondaryWhite,
    Color? textAccent,
    Color? textSecondaryAccent,
    Color? textLinks,
    Color? textSuccess,
    Color? textWarning,
    Color? iconBlack,
    Color? iconGrey,
    Color? iconLightGrey,
    Color? iconDisabled,
    Color? iconWhite,
    Color? iconAccent,
    Color? iconSecondaryAccent,
    Color? iconSuccess,
    Color? iconWarning,
    Color? surfaceWhite,
    Color? surfaceLightGrey,
  }) => AppSemanticColors(
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textGrey: textGrey ?? this.textGrey,
    textLightGrey: textLightGrey ?? this.textLightGrey,
    textDisabled: textDisabled ?? this.textDisabled,
    textPrimaryWhite: textPrimaryWhite ?? this.textPrimaryWhite,
    textSecondaryWhite: textSecondaryWhite ?? this.textSecondaryWhite,
    textAccent: textAccent ?? this.textAccent,
    textSecondaryAccent: textSecondaryAccent ?? this.textSecondaryAccent,
    textLinks: textLinks ?? this.textLinks,
    textSuccess: textSuccess ?? this.textSuccess,
    textWarning: textWarning ?? this.textWarning,
    iconBlack: iconBlack ?? this.iconBlack,
    iconGrey: iconGrey ?? this.iconGrey,
    iconLightGrey: iconLightGrey ?? this.iconLightGrey,
    iconDisabled: iconDisabled ?? this.iconDisabled,
    iconWhite: iconWhite ?? this.iconWhite,
    iconAccent: iconAccent ?? this.iconAccent,
    iconSecondaryAccent: iconSecondaryAccent ?? this.iconSecondaryAccent,
    iconSuccess: iconSuccess ?? this.iconSuccess,
    iconWarning: iconWarning ?? this.iconWarning,
    surfaceWhite: surfaceWhite ?? this.surfaceWhite,
    surfaceLightGrey: surfaceLightGrey ?? this.surfaceLightGrey,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textGrey: mix(textGrey, other.textGrey),
      textLightGrey: mix(textLightGrey, other.textLightGrey),
      textDisabled: mix(textDisabled, other.textDisabled),
      textPrimaryWhite: mix(textPrimaryWhite, other.textPrimaryWhite),
      textSecondaryWhite: mix(textSecondaryWhite, other.textSecondaryWhite),
      textAccent: mix(textAccent, other.textAccent),
      textSecondaryAccent: mix(textSecondaryAccent, other.textSecondaryAccent),
      textLinks: mix(textLinks, other.textLinks),
      textSuccess: mix(textSuccess, other.textSuccess),
      textWarning: mix(textWarning, other.textWarning),
      iconBlack: mix(iconBlack, other.iconBlack),
      iconGrey: mix(iconGrey, other.iconGrey),
      iconLightGrey: mix(iconLightGrey, other.iconLightGrey),
      iconDisabled: mix(iconDisabled, other.iconDisabled),
      iconWhite: mix(iconWhite, other.iconWhite),
      iconAccent: mix(iconAccent, other.iconAccent),
      iconSecondaryAccent: mix(iconSecondaryAccent, other.iconSecondaryAccent),
      iconSuccess: mix(iconSuccess, other.iconSuccess),
      iconWarning: mix(iconWarning, other.iconWarning),
      surfaceWhite: mix(surfaceWhite, other.surfaceWhite),
      surfaceLightGrey: mix(surfaceLightGrey, other.surfaceLightGrey),
    );
  }
}

/// Shortcut to the semantic colours of the current theme.
extension AppColorsContext on BuildContext {
  /// The semantic colour roles, e.g. `context.colors.textPrimary`.
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
