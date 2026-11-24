import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "Position" axis of the DS Tooltip (5248:1502): the edge of the
/// bubble the arrow sits on (`bottom` = arrow below the bubble).
enum AppTooltipPosition { top, bottom, left, right }

/// The static tooltip bubble: fill, label and the arrow on [position]'s edge.
///
/// Geometry from the DS: radius 8, padding 6 x 8, arrow 12 x 8 centred on its
/// edge and sticking out of the bubble. Fill is Sage-500 (the kit's blue),
/// text B3 white (the kit's Inter 14/20). The DS has a single size.
class AppTooltipBubble extends StatelessWidget {
  const AppTooltipBubble({
    super.key,
    required this.message,
    this.position = AppTooltipPosition.bottom,
  });

  static const radius = AppRadii.xs;
  static const verticalPadding = 6.0;
  static const horizontalPadding = AppSpacing.xs;

  /// Arrow extent along the edge it sits on.
  static const arrowBase = 12.0;

  /// How far the arrow sticks out of the bubble.
  static const arrowDepth = 8.0;

  static const color = AppColors.sage500;

  final String message;
  final AppTooltipPosition position;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.b3.copyWith(
          color: context.colors.textPrimaryWhite,
        ),
      ),
    );
    final alongX =
        position == AppTooltipPosition.top ||
        position == AppTooltipPosition.bottom;
    final arrow = CustomPaint(
      key: const Key('tooltip-arrow'),
      size: alongX
          ? const Size(arrowBase, arrowDepth)
          : const Size(arrowDepth, arrowBase),
      painter: _ArrowPainter(position),
    );
    final children = switch (position) {
      AppTooltipPosition.top || AppTooltipPosition.left => [arrow, bubble],
      AppTooltipPosition.bottom || AppTooltipPosition.right => [bubble, arrow],
    };
    return Semantics(
      container: true,
      child: alongX
          ? Column(mainAxisSize: MainAxisSize.min, children: children)
          : Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.position);

  final AppTooltipPosition position;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // The tip points away from the bubble.
    final path = switch (position) {
      AppTooltipPosition.bottom =>
        (Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w / 2, h)),
      AppTooltipPosition.top =>
        (Path()
          ..moveTo(0, h)
          ..lineTo(w, h)
          ..lineTo(w / 2, 0)),
      AppTooltipPosition.right =>
        (Path()
          ..moveTo(0, 0)
          ..lineTo(0, h)
          ..lineTo(w, h / 2)),
      AppTooltipPosition.left =>
        (Path()
          ..moveTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(0, h / 2)),
    }..close();
    canvas.drawPath(path, Paint()..color = AppTooltipBubble.color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.position != position;
}

/// Wraps [child] and shows an [AppTooltipBubble] beside it on long-press
/// (touch) or hover (mouse). It hides after [showDuration] or when the
/// pointer leaves. The arrow always faces the child.
class AppTooltip extends StatefulWidget {
  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.bubbleSide = AppTooltipPosition.top,
    this.showDuration = const Duration(seconds: 2),
  });

  /// Gap between the child and the bubble's arrow tip.
  static const gap = AppSpacing.xxs;

  final String message;
  final Widget child;

  /// Which side of the child the bubble appears on.
  final AppTooltipPosition bubbleSide;

  final Duration showDuration;

  @override
  State<AppTooltip> createState() => _AppTooltipState();
}

class _AppTooltipState extends State<AppTooltip> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  Timer? _timer;

  void _show() {
    _timer?.cancel();
    _portal.show();
    _timer = Timer(widget.showDuration, _hide);
  }

  void _hide() {
    _timer?.cancel();
    if (_portal.isShowing) _portal.hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// The arrow sits on the bubble edge that faces the child.
  AppTooltipPosition get _arrowPosition => switch (widget.bubbleSide) {
    AppTooltipPosition.top => AppTooltipPosition.bottom,
    AppTooltipPosition.bottom => AppTooltipPosition.top,
    AppTooltipPosition.left => AppTooltipPosition.right,
    AppTooltipPosition.right => AppTooltipPosition.left,
  };

  (Alignment, Alignment, Offset) get _anchors => switch (widget.bubbleSide) {
    AppTooltipPosition.top => (
      Alignment.topCenter,
      Alignment.bottomCenter,
      const Offset(0, -AppTooltip.gap),
    ),
    AppTooltipPosition.bottom => (
      Alignment.bottomCenter,
      Alignment.topCenter,
      const Offset(0, AppTooltip.gap),
    ),
    AppTooltipPosition.left => (
      Alignment.centerLeft,
      Alignment.centerRight,
      const Offset(-AppTooltip.gap, 0),
    ),
    AppTooltipPosition.right => (
      Alignment.centerRight,
      Alignment.centerLeft,
      const Offset(AppTooltip.gap, 0),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (target, follower, offset) = _anchors;
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Align(
        alignment: Alignment.topLeft,
        child: CompositedTransformFollower(
          link: _link,
          targetAnchor: target,
          followerAnchor: follower,
          offset: offset,
          showWhenUnlinked: false,
          child: IgnorePointer(
            child: UnconstrainedBox(
              child: AppTooltipBubble(
                message: widget.message,
                position: _arrowPosition,
              ),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: MouseRegion(
          onEnter: (_) => _show(),
          onExit: (_) => _hide(),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: _show,
            child: Semantics(tooltip: widget.message, child: widget.child),
          ),
        ),
      ),
    );
  }
}
