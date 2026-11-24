import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsProperties;

import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "Text Side" axis of the `Radio + Text`, `Checkbox + Text` and
/// `Toggle + Text` components.
///
/// Named as in Figma: with [left] the control comes first and the text follows
/// it (the layer order of the "Left" variants, and how every screen uses it);
/// with [right] the text comes first, right-aligned, and the control ends the
/// row.
enum AppTextSide { left, right }

/// Gap between a control and its text, as in the DS `+ Text` components.
const double selectionLabelGap = AppSpacing.md;

/// Width of the focus ring drawn outside a control (DS shadow spread 3).
const double selectionFocusRingWidth = 3;

/// Border width of radios and checkboxes.
const double selectionBorderWidth = 1.5;

/// Focus ring shadow shared by the DS selection controls.
const selectionFocusRing = BoxShadow(
  color: AppColors.sage300,
  spreadRadius: selectionFocusRingWidth,
);

/// Whether [states] contain [state].
extension SelectionStates on Set<WidgetState> {
  bool get isDisabled => contains(WidgetState.disabled);
  bool get isHovered => contains(WidgetState.hovered);
  bool get isFocused => contains(WidgetState.focused);
}

/// Hover, focus and tap handling shared by the selection controls.
///
/// Tracks the [WidgetState]s in a [WidgetStatesController] (the given one, or
/// its own) so galleries and goldens can preset hover or focus. A null [onTap]
/// means disabled: the `disabled` state is added to what the builder sees and
/// taps are ignored. No ripples.
class SelectionInteraction extends StatefulWidget {
  const SelectionInteraction({
    super.key,
    required this.onTap,
    required this.builder,
    this.statesController,
    this.semantics,
  });

  /// Null disables the control.
  final VoidCallback? onTap;

  /// Builds the visual from the current states.
  final Widget Function(BuildContext context, Set<WidgetState> states) builder;

  final WidgetStatesController? statesController;

  /// Semantics of the control (checked, toggled, ...); `enabled` is added.
  final SemanticsProperties? semantics;

  @override
  State<SelectionInteraction> createState() => _SelectionInteractionState();
}

class _SelectionInteractionState extends State<SelectionInteraction> {
  WidgetStatesController? _own;

  WidgetStatesController get _controller =>
      widget.statesController ?? (_own ??= WidgetStatesController());

  bool get _enabled => widget.onTap != null;

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  void _set(WidgetState state, bool on) {
    if (!_enabled) return;
    _controller.update(state, on);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final states = {..._controller.value};
        if (_enabled) {
          states.remove(WidgetState.disabled);
        } else {
          states.add(WidgetState.disabled);
        }
        final properties = widget.semantics;
        return Semantics(
          enabled: _enabled,
          checked: properties?.checked,
          toggled: properties?.toggled,
          inMutuallyExclusiveGroup: properties?.inMutuallyExclusiveGroup,
          mixed: properties?.mixed,
          onTap: widget.onTap,
          child: FocusableActionDetector(
            enabled: _enabled,
            mouseCursor: _enabled
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            onShowHoverHighlight: (v) => _set(WidgetState.hovered, v),
            onShowFocusHighlight: (v) => _set(WidgetState.focused, v),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: widget.builder(context, states),
            ),
          ),
        );
      },
    );
  }
}

/// A control with an optional label beside it, in the DS `+ Text` layout.
class SelectionRow extends StatelessWidget {
  const SelectionRow({
    super.key,
    required this.control,
    required this.label,
    required this.textSide,
    required this.disabled,
  });

  final Widget control;
  final String? label;
  final AppTextSide textSide;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label == null) return control;
    final AppSemanticColors colors =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    final left = textSide == AppTextSide.left;
    final text = Flexible(
      child: Text(
        label,
        textAlign: left ? TextAlign.start : TextAlign.end,
        style: AppTypography.b1.copyWith(
          color: disabled ? colors.textGrey : colors.textPrimary,
        ),
      ),
    );
    const gap = SizedBox(width: selectionLabelGap);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: left ? [control, gap, text] : [text, gap, control],
    );
  }
}
