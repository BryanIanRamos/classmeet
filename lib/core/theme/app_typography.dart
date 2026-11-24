import 'package:flutter/painting.dart';

/// The ClassMeet type scale, from the Figma text styles
/// (`design/notes/tokens.md`).
///
/// Sizes and line heights are in dp. Each style sets
/// `height = lineHeight / fontSize` with even leading, so a line box is exactly
/// the Figma line height. Styles carry no colour: they inherit it from the
/// surrounding `DefaultTextStyle` or take one with `copyWith(color: ...)`.
///
/// Headings/H4 is not used anywhere in the file (checked in task 1.5).
/// Two styles carry no Figma style but recur on screens: [c3Medium] and
/// [h3ExtraBold].
abstract final class AppTypography {
  /// Font family for every style except the `inter*` ones.
  static const jakarta = 'PlusJakartaSans';

  /// Font family of the Figma "Text Font" styles.
  static const inter = 'Inter';

  // Headings.

  /// Headings/H1: 48/58 SemiBold.
  static const h1 = TextStyle(
    fontFamily: jakarta,
    fontSize: 48,
    height: 58 / 48,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Headings/H2: 40/48 SemiBold.
  static const h2 = TextStyle(
    fontFamily: jakarta,
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Headings/H3: 32/38 SemiBold.
  static const h3 = TextStyle(
    fontFamily: jakarta,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 32/38 ExtraBold, no Figma style: the onboarding headlines (frames 94
  /// and 95).
  static const h3ExtraBold = TextStyle(
    fontFamily: jakarta,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Headings/H5: 24/28 SemiBold.
  static const h5 = TextStyle(
    fontFamily: jakarta,
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Subtitles.

  /// Subtitle/S1: 18/28 SemiBold.
  static const s1 = TextStyle(
    fontFamily: jakarta,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Subtitle/S2: 16/24 SemiBold.
  static const s2 = TextStyle(
    fontFamily: jakarta,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Body.

  /// Body/B1: 16/24 Regular.
  static const b1 = TextStyle(
    fontFamily: jakarta,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Body/B2: 16/24 Medium.
  static const b2 = TextStyle(
    fontFamily: jakarta,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Body/B3: 14/20 Regular.
  static const b3 = TextStyle(
    fontFamily: jakarta,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Body/B4: 14/20 Medium.
  static const b4 = TextStyle(
    fontFamily: jakarta,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Captions.

  /// Caption/C1: 12/16 Regular.
  static const c1 = TextStyle(
    fontFamily: jakarta,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Caption/C2: 12/16 Medium.
  static const c2 = TextStyle(
    fontFamily: jakarta,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Caption/C3: 10/14 Regular.
  static const c3 = TextStyle(
    fontFamily: jakarta,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Caption/C3 with the Medium weight Figma applies as an override: progress
  /// labels and the bottom-nav labels, 10/14 Medium.
  static const c3Medium = TextStyle(
    fontFamily: jakarta,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Buttons.

  /// Button/Giant: 18/24 SemiBold.
  static const buttonGiant = TextStyle(
    fontFamily: jakarta,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Button/Large: 16/20 SemiBold.
  static const buttonLarge = TextStyle(
    fontFamily: jakarta,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Button/Medium: 14/16 SemiBold.
  static const buttonMedium = TextStyle(
    fontFamily: jakarta,
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Button/Small: 12/16 SemiBold.
  static const buttonSmall = TextStyle(
    fontFamily: jakarta,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Button/Tiny: 10/12 SemiBold.
  static const buttonTiny = TextStyle(
    fontFamily: jakarta,
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // Inter ("Text Font" styles).

  /// Text Font/C1 Caption: Inter 12/16 Regular.
  static const interC1 = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Text Font/B1 Body: Inter 16/24 Regular.
  static const interB1 = TextStyle(
    fontFamily: inter,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Every style by its Figma text-style name (the two styles without one are
  /// named after their base style). Used by the token gallery and the
  /// tests.
  static const Map<String, TextStyle> byFigmaName = {
    'Headings/H1': h1,
    'Headings/H2': h2,
    'Headings/H3': h3,
    'Headings/H3 ExtraBold': h3ExtraBold,
    'Headings/H5': h5,
    'Subtitle/S1': s1,
    'Subtitle/S2': s2,
    'Body/B1': b1,
    'Body/B2': b2,
    'Body/B3': b3,
    'Body/B4': b4,
    'Caption/C1': c1,
    'Caption/C2': c2,
    'Caption/C3': c3,
    'Caption/C3 Medium': c3Medium,
    'Button/Giant': buttonGiant,
    'Button/Large': buttonLarge,
    'Button/Medium': buttonMedium,
    'Button/Small': buttonSmall,
    'Button/Tiny': buttonTiny,
    'Text Font/C1 Caption': interC1,
    'Text Font/B1 Body': interB1,
  };
}
