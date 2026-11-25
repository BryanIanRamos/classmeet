import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Where the label sits relative to the bar (DS "Position" axis).
enum AppProgressBarLabelPosition { left, right }

/// The ClassMeet progress bar (DS Progress Bar, Figma 5248:1858).
///
/// [value] is clamped to 0..1. Without [segments] it is a continuous fill.
/// With [segments] (the Home look uses 5) the bar is split into equal
/// segments and the fill is discrete: a segment is filled once the value
/// reaches into it (67% fills 4 of 5, as in the Home design). [segmentGap] is
/// 0 on the Home cards, where the bar is one square-ended fill on the track;
/// with a gap above 0 it draws separate rounded pills with nothing between
/// them (the question counter of 15: 6 tall, gap 6). [height] is 8 unless a
/// screen says otherwise.
///
/// An optional [label] (e.g. "67%" or "171/300") sits [labelPosition] of the
/// bar, 4dp away, in C3 Medium (screens; the DS sheet shows 16dp and Inter
/// 14/20). Colours: [color] on [trackColor], Sage-500 on Grey-200 by default
/// (the DS kit's blue and light blue); [labelColor] defaults to the primary
/// text colour. [enabled] false is the DS Disabled state (Grey-100 track,
/// grey label). No animation.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.segments,
    this.segmentGap = AppSpacing.none,
    this.label,
    this.labelPosition = AppProgressBarLabelPosition.right,
    this.color = AppColors.sage500,
    this.trackColor = AppColors.grey200,
    this.labelColor,
    this.enabled = true,
    this.semanticLabel,
    this.height = barHeight,
  }) : assert(segments == null || segments > 0);

  /// Height of the bar (DS and screens: 8).
  static const barHeight = 8.0;

  /// Corner radius of the bar (and the fill).
  static const radius = AppRadii.xs;

  /// Gap between the bar and its label.
  static const labelGap = AppSpacing.xxs;

  /// Track colour of the disabled state.
  static const disabledTrack = AppColors.grey100;

  final double value;
  final int? segments;
  final double segmentGap;
  final String? label;
  final AppProgressBarLabelPosition labelPosition;
  final Color color;
  final Color trackColor;
  final Color? labelColor;
  final bool enabled;
  final String? semanticLabel;

  /// Bar height; separate segments are fully rounded pills of this height.
  final double height;

  double get _value => value.isNaN ? 0 : value.clamp(0.0, 1.0);

  /// How many segments are filled (segmented look).
  int get filledSegments {
    final count = segments;
    if (count == null) return 0;
    // The epsilon keeps 0.4 * 5 = 2.0000000000000004 at 2 segments.
    return (_value * count - 1e-9).ceil().clamp(0, count);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = label == null ? null : _label(colors);
    final labelLeft = labelPosition == AppProgressBarLabelPosition.left;
    final row = Row(
      children: [
        if (text != null && labelLeft) ...[
          text,
          const SizedBox(width: labelGap),
        ],
        Expanded(child: _bar()),
        if (text != null && !labelLeft) ...[
          const SizedBox(width: labelGap),
          text,
        ],
      ],
    );
    return Semantics(
      label: semanticLabel,
      value: '${(_value * 100).round()}%',
      excludeSemantics: semanticLabel != null,
      child: row,
    );
  }

  Widget _label(AppSemanticColors colors) {
    return Text(
      label!,
      maxLines: 1,
      style: AppTypography.c3Medium.copyWith(
        color: enabled ? labelColor ?? colors.textPrimary : colors.textGrey,
      ),
    );
  }

  Widget _bar() {
    final track = enabled ? trackColor : disabledTrack;
    final fill = enabled ? color : disabledTrack;
    if (segments != null && segmentGap > 0) {
      // Separate pills: no track behind them, so the gaps stay empty.
      return SizedBox(
        height: height,
        child: Row(
          children: [
            for (var i = 0; i < segments!; i++) ...[
              if (i > 0) SizedBox(width: segmentGap),
              Expanded(
                child: DecoratedBox(
                  key: ValueKey('progress-segment-$i'),
                  decoration: BoxDecoration(
                    color: i < filledSegments ? fill : track,
                    borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(radius)),
        child: ColoredBox(
          color: track,
          child: segments == null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _value,
                    heightFactor: 1,
                    child: DecoratedBox(
                      key: const ValueKey('progress-fill'),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(radius),
                        ),
                      ),
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: filledSegments / segments!,
                    heightFactor: 1,
                    child: ColoredBox(
                      key: const ValueKey('progress-fill'),
                      color: fill,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
