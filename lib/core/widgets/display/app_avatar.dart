import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../assets/app_images.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_typography.dart';

/// Figma "Size" axis of the Design System Avatar (5248:1634), with the
/// measurements of each size.
///
/// The letter styles are the closest [AppTypography] styles to the DS sheet
/// values: tiny 12/16, small 16/24, medium 18/28, large 24/28 and xl 32/38
/// match exactly. The DS giant 28/34 is off-scale and uses H5 (24/28). The
/// DS xxl and xxxl 48/58 use H1.
enum AppAvatarSize {
  tiny(
    diameter: 24,
    dot: 8,
    dotBorder: 1.5,
    iconSize: 12,
    letterStyle: AppTypography.c2,
  ),
  small(
    diameter: 32,
    dot: 10,
    dotBorder: 1.5,
    iconSize: 16,
    letterStyle: AppTypography.s2,
  ),
  medium(
    diameter: 40,
    dot: 12,
    dotBorder: 2,
    iconSize: 20,
    letterStyle: AppTypography.s1,
  ),
  large(
    diameter: 48,
    dot: 12,
    dotBorder: 2,
    iconSize: 24,
    letterStyle: AppTypography.h5,
  ),
  giant(
    diameter: 56,
    dot: 16,
    dotBorder: 2.5,
    iconSize: 28,
    letterStyle: AppTypography.h5,
  ),
  xlGiant(
    diameter: 64,
    dot: 16,
    dotBorder: 2.5,
    iconSize: 32,
    letterStyle: AppTypography.h3,
  ),
  xxlGiant(
    diameter: 80,
    dot: 20,
    dotBorder: 3,
    iconSize: 40,
    letterStyle: AppTypography.h1,
  ),
  xxxlGiant(
    diameter: 96,
    dot: 24,
    dotBorder: 3,
    iconSize: 48,
    letterStyle: AppTypography.h1,
  );

  const AppAvatarSize({
    required this.diameter,
    required this.dot,
    required this.dotBorder,
    required this.iconSize,
    required this.letterStyle,
  });

  /// Width and height of the circle.
  final double diameter;

  /// Diameter of the status dot, including its white ring.
  final double dot;

  /// Width of the white ring around the status dot.
  final double dotBorder;

  /// Glyph size of the icon type (half the diameter).
  final double iconSize;

  final TextStyle letterStyle;
}

/// The ClassMeet avatar: a circle showing an image, a letter or an icon, with
/// an optional online status dot at the bottom right.
///
/// Build it with [AppAvatar.image], [AppAvatar.asset], [AppAvatar.letter] or
/// [AppAvatar.icon]. The letter and icon types fill the circle with
/// [backgroundColor]: Sage-500 by default (the DS kit's blue), and the tint
/// the screen gives it, e.g. Sprout-300 on the quiz leaderboard.
class AppAvatar extends StatelessWidget {
  /// A photo or illustration from any [ImageProvider].
  const AppAvatar.image({
    super.key,
    required ImageProvider this.imageProvider,
    this.size = AppAvatarSize.small,
    this.showStatus = false,
    this.semanticLabel,
  }) : letter = null,
       icon = null,
       backgroundColor = AppColors.sage500;

  /// An [AppImage] asset, decoded at its logical size.
  AppAvatar.asset(
    AppImage image, {
    super.key,
    this.size = AppAvatarSize.small,
    this.showStatus = false,
    this.semanticLabel,
  }) : imageProvider = ResizeImage(
         AssetImage(image.path),
         width: (size.diameter * _cachePixelRatio).round(),
       ),
       letter = null,
       icon = null,
       backgroundColor = AppColors.sage500;

  /// The first character of [letter], upper-cased.
  const AppAvatar.letter({
    super.key,
    required String this.letter,
    this.size = AppAvatarSize.small,
    this.showStatus = false,
    this.backgroundColor = AppColors.sage500,
    this.semanticLabel,
  }) : imageProvider = null,
       icon = null;

  /// A glyph on a coloured circle ([AppIcons.smile], the DS "emoji", by
  /// default).
  const AppAvatar.icon({
    super.key,
    this.icon = AppIcons.smile,
    this.size = AppAvatarSize.small,
    this.showStatus = false,
    this.backgroundColor = AppColors.sage500,
    this.semanticLabel,
  }) : imageProvider = null,
       letter = null;

  /// Decode scale for [AppAvatar.asset] (3x assets).
  static const _cachePixelRatio = 3;

  final AppAvatarSize size;
  final ImageProvider? imageProvider;
  final String? letter;
  final IconData? icon;

  /// Shows the green status dot ("online") at the bottom right.
  final bool showStatus;

  /// Fill of the letter and icon types.
  final Color backgroundColor;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diameter = size.diameter;
    return Semantics(
      label: semanticLabel,
      image: imageProvider != null,
      child: SizedBox.square(
        dimension: diameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: ClipOval(child: _face(colors))),
            if (showStatus)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  key: const ValueKey('avatar-dot'),
                  width: size.dot,
                  height: size.dot,
                  decoration: BoxDecoration(
                    color: AppColors.sprout500,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: size.dotBorder,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _face(AppSemanticColors colors) {
    if (imageProvider case final provider?) {
      return Image(
        image: provider,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      );
    }
    final Widget content;
    if (letter case final letter?) {
      final first = letter.isEmpty ? '' : letter.substring(0, 1).toUpperCase();
      content = Text(
        first,
        style: size.letterStyle.copyWith(color: colors.textPrimaryWhite),
      );
    } else {
      content = Icon(icon, size: size.iconSize, color: colors.iconWhite);
    }
    return ColoredBox(
      color: backgroundColor,
      child: Center(child: content),
    );
  }
}
