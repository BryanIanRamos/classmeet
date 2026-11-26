import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// "Before you join" and the ask-your-teacher line at the foot of Join a class
/// (frame 13.1, "Frame 1188"): a shield and a heading, a centred note whose
/// last words, "My Classes", are a Talon-700 link, and a grey line under it.
///
/// The spec gives no width for the note. It breaks after "before" in the
/// design, which needs a width between its second line (279) and the first
/// line plus "confirming." (301), so it is held to [noteWidth].
class JoinInfo extends StatefulWidget {
  const JoinInfo({super.key, required this.onMyClasses});

  /// The "My Classes" link was tapped.
  final VoidCallback onMyClasses;

  /// Width the note wraps at; wide enough for its second line and too narrow
  /// to pull "confirming." up into the first.
  static const noteWidth = 290.0;

  /// Size of the shield icon.
  static const iconSize = 16.0;

  /// Gap between the heading and the note (spec "Frame 1169").
  static const _headingGap = AppSpacing.xs;

  /// Gap between the note and the last line (spec "Frame 1188").
  static const _lineGap = AppSpacing.xl;

  @override
  State<JoinInfo> createState() => _JoinInfoState();
}

class _JoinInfoState extends State<JoinInfo> {
  late final TapGestureRecognizer _myClasses = TapGestureRecognizer()
    ..onTap = () => widget.onMyClasses();

  @override
  void dispose() {
    _myClasses.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final grey = AppTypography.c1.copyWith(color: colors.textSecondary);
    final link = AppTypography.c1.copyWith(color: AppColors.talon700);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              AppIcons.shieldCheck,
              size: JoinInfo.iconSize,
              color: AppColors.talon700,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Flexible(
              child: Text(
                'Before you join',
                style: AppTypography.b3.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: JoinInfo._headingGap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: JoinInfo.noteWidth),
          child: Text.rich(
            TextSpan(
              text:
                  'Check the class name and teacher before confirming. '
                  "You'll then see the class in ",
              style: grey,
              children: [
                TextSpan(
                  text: 'My Classes',
                  recognizer: _myClasses,
                  style: link,
                ),
                // The design colours the full stop with the link.
                TextSpan(text: '.', style: link),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: JoinInfo._lineGap),
        Text(
          "Don't have a code? Ask your teacher or class administrator.",
          textAlign: TextAlign.center,
          style: grey,
        ),
      ],
    );
  }
}
