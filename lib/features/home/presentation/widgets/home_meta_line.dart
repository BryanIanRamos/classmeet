import 'package:flutter/material.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// A one-line caption of parts separated by "·", as the Home cards draw it
/// (frame 8): "3 activities left · In 5 days" or "+5 talons · Resets at
/// midnight".
///
/// Figma lays these out as separate texts with [gap] on each side of the
/// dot: 4 on the goal and material cards, 10 on the quest cards. Here it is
/// one paragraph with fixed-width gaps, so the whole line ellipsizes at its
/// end instead of overflowing (narrow screens, large text scales). Parts are
/// C1 Grey-500 unless they set their own style. Screen readers hear the dot
/// as a pause.
class HomeMetaLine extends StatelessWidget {
  const HomeMetaLine({
    super.key,
    required this.parts,
    this.gap = AppSpacing.xxs,
  });

  final List<TextSpan> parts;

  /// Space on each side of a dot.
  final double gap;

  /// The quest cards' gap (spec 8, "Frame 1302": gap 10).
  static const wideGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final space = WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: SizedBox(width: gap),
    );
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) ...[
              space,
              const TextSpan(text: '·', semanticsLabel: ', '),
              space,
            ],
            parts[i],
          ],
        ],
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.c1.copyWith(color: context.colors.textSecondary),
    );
  }
}
