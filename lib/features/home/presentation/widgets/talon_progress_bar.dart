import 'package:flutter/material.dart';

import '../../../../core/widgets/feedback/app_progress_bar.dart';

/// The progress bar of Talon credits (frame 14): the next-reward bar and the
/// bar of each quest card. An [AppProgressBar] 8 tall, [color] on
/// [trackColor], with the optional [label] on its right.
///
/// The Design System bar is flat rectangles inside a rounded track, so the
/// fill ends square (`flatFill`), as Home's segmented bars do.
class TalonProgressBar extends StatelessWidget {
  const TalonProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.label,
    this.labelColor,
  });

  /// Fill of the bar, 0 to 1 (clamped).
  final double value;
  final Color color;
  final Color trackColor;

  /// Text on the right of the bar, e.g. "171/300".
  final String? label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return AppProgressBar(
      value: value,
      flatFill: true,
      color: color,
      trackColor: trackColor,
      label: label,
      labelColor: labelColor,
    );
  }
}
