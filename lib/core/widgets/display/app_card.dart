import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The ClassMeet card (DS Card 5248:10244 and the Home list cards).
///
/// The default constructor is the card of the screens: Grey-50 fill, Grey-300
/// 1px border, radius 16, padding 16, holding any [child]. [AppCard.vertical]
/// and [AppCard.horizontalSmall] are the DS layouts (image area plus text);
/// they use the DS white fill and shadow 500, with radius 16 as on the
/// screens (the kit shows 12) and Plus Jakarta Sans: title S2 (kit Inter
/// 16/24 w600), description B3 grey-500 (kit Inter 14/20).
///
/// With a null [onTap] the card is static. Pressing shows [pressedColor]
/// (flat, no ripple).
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.grey50,
    this.pressedColor = AppColors.grey100,
    this.borderColor = AppColors.grey300,
    this.radius = AppRadii.md,
    this.shadows,
    this.semanticLabel,
  });

  /// DS "Card (Vertical)": [image] on top, then [title] and [description],
  /// then [children] (e.g. buttons) with 24 padding and gap.
  factory AppCard.vertical({
    Key? key,
    required Widget image,
    String? title,
    String? description,
    List<Widget> children = const [],
    double imageHeight = verticalImageHeight,
    VoidCallback? onTap,
  }) {
    return AppCard._layout(
      key: key,
      onTap: onTap,
      child: _VerticalContent(
        image: image,
        imageHeight: imageHeight,
        title: title,
        description: description,
        children: children,
      ),
    );
  }

  /// DS "Card (Horizontal - Small)": a 120 square [image] left, text right.
  factory AppCard.horizontalSmall({
    Key? key,
    required Widget image,
    String? title,
    String? description,
    VoidCallback? onTap,
  }) {
    return AppCard._layout(
      key: key,
      onTap: onTap,
      child: SizedBox(
        height: horizontalHeight,
        child: Row(
          children: [
            SizedBox.square(dimension: horizontalHeight, child: image),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _TitleDescription(
                  title: title,
                  description: description,
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  const AppCard._layout({super.key, required this.child, this.onTap})
    : padding = EdgeInsets.zero,
      color = AppColors.white,
      pressedColor = AppColors.grey50,
      borderColor = null,
      radius = AppRadii.md,
      shadows = AppShadows.s500,
      semanticLabel = null;

  /// Height of the image area of the vertical card (DS default variant).
  static const verticalImageHeight = 200.0;

  /// Height of the horizontal-small card, and the width of its image.
  static const horizontalHeight = 120.0;

  /// Lines of description shown by the vertical card.
  static const verticalDescriptionLines = 4;

  /// Padding of the vertical card content.
  static const contentPadding = AppSpacing.xl;

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color pressedColor;

  /// Null draws no border.
  final Color? borderColor;
  final double radius;
  final List<BoxShadow>? shadows;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final radius = BorderRadius.circular(widget.radius);
    final borderColor = widget.borderColor;
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: enabled && _pressed ? widget.pressedColor : widget.color,
        borderRadius: radius,
        border: borderColor == null ? null : Border.all(color: borderColor),
        boxShadow: widget.shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
    if (enabled) {
      card = Semantics(
        button: true,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: card,
        ),
      );
    }
    return card;
  }
}

class _TitleDescription extends StatelessWidget {
  const _TitleDescription({this.title, this.description, this.maxLines});

  final String? title;
  final String? description;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.s2.copyWith(color: colors.textPrimary),
          ),
        if (title != null && description != null)
          const SizedBox(height: AppSpacing.xxs),
        if (description != null)
          Flexible(
            child: Text(
              description!,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.b3.copyWith(color: colors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _VerticalContent extends StatelessWidget {
  const _VerticalContent({
    required this.image,
    required this.imageHeight,
    required this.title,
    required this.description,
    required this.children,
  });

  final Widget image;
  final double imageHeight;
  final String? title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final hasText = title != null || description != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: imageHeight, child: image),
        if (hasText || children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(AppCard.contentPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasText)
                  _TitleDescription(
                    title: title,
                    description: description,
                    maxLines: AppCard.verticalDescriptionLines,
                  ),
                if (hasText && children.isNotEmpty)
                  const SizedBox(height: AppSpacing.xl),
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  children[i],
                ],
              ],
            ),
          ),
      ],
    );
  }
}
