import 'package:flutter/material.dart';

import '../../assets/app_images.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import 'app_illustration.dart';

/// A card with illustration art behind Flutter-rendered text (D-01): the art
/// is a text-free export of the Figma card, the copy is real text on top.
///
/// The card fills the available width (360–428 dp screens). The art covers
/// the card, anchored to [artAlignment] (right by default, where Ollie and
/// the props sit), so narrower screens crop the plain left side. Until the
/// art exists ([art] null, or a missing file) the card's own [color] is the
/// placeholder.
///
/// Home examples: the hero card (Sage-300 fill and border), the streak card
/// (Ember-500 with an Ember-700 border) and the talon card (Talon-500 with a
/// Talon-700 border), all radius 16.
class IllustratedCard extends StatelessWidget {
  const IllustratedCard({
    super.key,
    required this.child,
    this.art,
    this.color = AppColors.sage300,
    this.borderColor,
    this.minHeight,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.md,
    this.artAlignment = Alignment.centerRight,
    this.onTap,
  });

  /// The text and controls drawn over the art.
  final Widget child;

  /// Text-free card art; null shows the plain [color].
  final AppImage? art;

  final Color color;

  /// 1 dp border; defaults to [color] (the hero card's border matches its
  /// fill).
  final Color? borderColor;

  /// Design height of the card, e.g. 189 for the Home hero card.
  final double? minHeight;

  final EdgeInsetsGeometry padding;
  final double radius;
  final Alignment artAlignment;
  final VoidCallback? onTap;

  static const borderWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.all(Radius.circular(radius));
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: shape,
        border: Border.all(color: borderColor ?? color),
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight ?? 0),
          child: Stack(
            children: [
              if (art case final image?)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, box) => AppIllustration(
                      image,
                      width: box.maxWidth,
                      height: box.maxHeight,
                      fit: BoxFit.cover,
                      alignment: artAlignment,
                      placeholderColor: color,
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
    // Fills the parent's width (needs a bounded width, e.g. Expanded in a Row).
    final wide = SizedBox(width: double.infinity, child: card);
    if (onTap == null) return wide;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: wide,
    );
  }
}
