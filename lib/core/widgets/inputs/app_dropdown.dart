import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'app_text_field.dart';

/// One option of an [AppDropdown].
@immutable
class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;

  /// Leading icon of the row (DS "Icon Left"), also shown in the closed
  /// field once the option is selected.
  final IconData? icon;

  /// False greys the row out and ignores taps (DS "Disabled").
  final bool enabled;
}

/// The menu panel of the DS "Expanded Menu (5 Rows)" (Figma 5248:10319):
/// white, radius 8, 8 padding above and below, 48 high rows 8 apart, a check
/// at the end of the selected row.
///
/// [AppDropdown] shows it in an overlay; it is public so galleries can lay it
/// out like the DS sheet. [hoveredIndex] paints one row in its hover state.
class AppDropdownMenu<T> extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.hoveredIndex,
  });

  /// Height of a row.
  static const rowHeight = 48.0;

  /// Space between two rows and above and below the list.
  static const rowGap = AppSpacing.xs;

  /// Size of the row icon and the check.
  static const iconSize = 24.0;

  /// Key of the panel: `ValueKey('AppDropdownMenu')`.
  static const menuKey = ValueKey<String>('AppDropdownMenu');

  /// Key of a row: `ValueKey('AppDropdownMenu.row.<index>')`.
  static ValueKey<String> rowKey(int index) =>
      ValueKey<String>('AppDropdownMenu.row.$index');

  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T> onSelected;
  final int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: menuKey,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.xs)),
        boxShadow: AppShadows.s500,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xs)),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: rowGap),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: rowGap),
          itemBuilder: (context, index) => _Row<T>(
            key: rowKey(index),
            item: items[index],
            selected: items[index].value == value,
            forceHover: index == hoveredIndex,
            onTap: () => onSelected(items[index].value),
          ),
        ),
      ),
    );
  }
}

class _Row<T> extends StatefulWidget {
  const _Row({
    super.key,
    required this.item,
    required this.selected,
    required this.forceHover,
    required this.onTap,
  });

  final AppDropdownItem<T> item;
  final bool selected;
  final bool forceHover;
  final VoidCallback onTap;

  @override
  State<_Row<T>> createState() => _RowState<T>();
}

class _RowState<T> extends State<_Row<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = widget.item;
    final enabled = item.enabled;
    final hovered = enabled && (_hovered || widget.forceHover);
    final textColor = enabled ? colors.textPrimary : colors.textGrey;
    final iconColor = enabled ? colors.iconGrey : colors.iconLightGrey;
    return Semantics(
      button: true,
      selected: widget.selected,
      enabled: enabled,
      label: item.label,
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: hovered ? AppColors.sage50 : Colors.transparent,
            ),
            child: SizedBox(
              height: AppDropdownMenu.rowHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    if (item.icon case final icon?) ...[
                      Icon(
                        icon,
                        size: AppDropdownMenu.iconSize,
                        color: iconColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.b1.copyWith(color: textColor),
                      ),
                    ),
                    if (widget.selected) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        AppIcons.check,
                        size: AppDropdownMenu.iconSize,
                        color: enabled ? AppColors.sage500 : iconColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The ClassMeet dropdown: a field that looks like [AppTextField] (label,
/// placeholder, helper or error text, leading icon, disabled state) with a
/// chevron, and opens a menu of [items] (DS Dropdown, Figma 5248:10319).
///
/// A null [onChanged] disables it. While the menu is open the field shows the
/// DS "Expanded" state: Sage-500 border with a 3 wide Sage-300 ring and the
/// chevron turned up. The menu opens under the field, or above when it does
/// not fit below. Tapping outside the menu closes it.
///
/// Geometry and colours match [AppTextField] (Large 48 / radius 12 or Medium
/// 40 / radius 8; kit blue becomes Sage-500, hover is the grey-400 border).
/// The DS shows one icon at the start of the field; here [leadingIcon] or
/// the selected item's icon is shown. Pass a [statesController] to show
/// hover or focus without interaction, and [initiallyOpen] to start with
/// the menu open (galleries, goldens).
class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.size = AppTextFieldSize.large,
    this.leadingIcon,
    this.accentColor,
    this.confirmSelection = false,
    this.statesController,
    this.initiallyOpen = false,
  });

  /// Key of the closed field box: `ValueKey('AppDropdown.box')`.
  static const boxKey = ValueKey<String>('AppDropdown.box');

  /// Width of the focus ring around the open field.
  static const ringWidth = 3.0;

  /// Space between the field and its menu.
  static const menuOffset = AppSpacing.xs;

  /// Tallest menu (DS "Expanded Menu (5 Rows)": 288); longer lists scroll.
  static const menuMaxHeight = 288.0;

  final List<AppDropdownItem<T>> items;

  /// The selected item's value, or null for none (the placeholder shows).
  final T? value;

  /// Called with the chosen value. Null disables the dropdown.
  final ValueChanged<T>? onChanged;

  final String? label;
  final String? placeholder;
  final String? helperText;

  /// Shown instead of [helperText] in the error colour.
  final String? errorText;
  final AppTextFieldSize size;
  final IconData? leadingIcon;

  /// Replaces the idle border, placeholder and icon colour.
  final Color? accentColor;

  /// When true, a field with a selected value shows the "done" look of
  /// screen 96 (School): a Grey-900 border and a check instead of the
  /// chevron, until it is opened again.
  final bool confirmSelection;
  final WidgetStatesController? statesController;
  final bool initiallyOpen;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _boxKey = GlobalKey();
  bool _hovered = false;
  bool _focused = false;
  bool _open = false;
  bool _flip = false;
  double _width = 0;

  bool get _enabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    widget.statesController?.addListener(_onStates);
    if (widget.initiallyOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _enabled) _openMenu();
      });
    }
  }

  @override
  void didUpdateWidget(AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statesController != widget.statesController) {
      oldWidget.statesController?.removeListener(_onStates);
      widget.statesController?.addListener(_onStates);
    }
    if (!_enabled && _open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _closeMenu();
      });
    }
  }

  @override
  void dispose() {
    widget.statesController?.removeListener(_onStates);
    super.dispose();
  }

  void _onStates() => setState(() {});

  bool _has(WidgetState state, bool real) =>
      real || (widget.statesController?.value.contains(state) ?? false);

  void _openMenu() {
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject();
    if (box != null && box.hasSize && overlay is RenderBox) {
      _width = box.size.width;
      final top = box.localToGlobal(Offset.zero, ancestor: overlay).dy;
      final below = overlay.size.height - top - box.size.height;
      final needed = math.min(
        AppDropdown.menuMaxHeight,
        widget.items.length *
                (AppDropdownMenu.rowHeight + AppDropdownMenu.rowGap) +
            AppDropdownMenu.rowGap,
      );
      _flip = below < needed + AppDropdown.menuOffset && top > below;
    }
    setState(() => _open = true);
    _portal.show();
  }

  void _closeMenu() {
    if (!_open) return;
    _portal.hide();
    setState(() => _open = false);
  }

  void _toggle() => _open ? _closeMenu() : _openMenu();

  void _select(T value) {
    _closeMenu();
    widget.onChanged?.call(value);
  }

  AppDropdownItem<T>? get _selected {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = _enabled;
    final size = widget.size;
    final focused = enabled && _has(WidgetState.focused, _focused);
    final hovered = enabled && _has(WidgetState.hovered, _hovered);
    final expanded = enabled && _open;
    final hasError = widget.errorText != null;
    final selected = _selected;
    final done =
        widget.confirmSelection && selected != null && enabled && !hasError;
    final accent = done ? null : widget.accentColor;
    final helper = widget.errorText ?? widget.helperText;

    final Color border;
    if (!enabled) {
      border = AppColors.grey200;
    } else if (hasError) {
      border = AppColors.ember500;
    } else if (expanded || focused) {
      border = AppColors.sage500;
    } else if (done) {
      border = AppColors.grey900;
    } else if (accent != null) {
      border = accent;
    } else {
      border = hovered ? AppColors.grey400 : AppColors.grey200;
    }

    final Color iconColor;
    if (!enabled) {
      iconColor = colors.iconLightGrey;
    } else if (hasError) {
      iconColor = AppColors.ember500;
    } else if (expanded || focused) {
      iconColor = AppColors.sage500;
    } else if (done) {
      iconColor = colors.iconBlack;
    } else {
      iconColor = accent ?? colors.iconGrey;
    }

    final textColor = selected != null && enabled
        ? colors.textPrimary
        : (enabled ? accent : null) ?? colors.textGrey;
    final leading = selected?.icon ?? widget.leadingIcon;
    final text = selected?.label ?? widget.placeholder ?? '';

    final box = SizedBox(
      key: _boxKey,
      height: size.height,
      child: DecoratedBox(
        key: AppDropdown.boxKey,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(size.radius)),
          border: Border.all(color: border, width: AppTextField.borderWidth),
          boxShadow: expanded && !hasError
              ? const [
                  BoxShadow(
                    color: AppColors.sage300,
                    spreadRadius: AppDropdown.ringWidth,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              if (leading != null) ...[
                Icon(leading, size: AppTextField.iconSize, color: iconColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: size.textStyle.copyWith(color: textColor),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (done && !expanded)
                Icon(
                  AppIcons.check,
                  size: AppTextField.iconSize,
                  color: iconColor,
                )
              else
                RotatedBox(
                  quarterTurns: expanded ? 2 : 0,
                  child: Icon(
                    AppIcons.chevronDown,
                    size: AppTextField.iconSize,
                    color: iconColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final helperColor = !enabled
        ? colors.textGrey
        : hasError
        ? AppColors.ember500
        : (expanded || focused)
        ? AppColors.sage500
        : colors.textGrey;

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildMenu,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.label case final label?) ...[
            SizedBox(
              height: AppTextField.labelHeight,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.b4.copyWith(
                  color: colors.textPrimary,
                  height: AppTextField.labelHeight / AppTypography.b4.fontSize!,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Semantics(
            button: true,
            enabled: enabled,
            expanded: expanded,
            label: widget.label,
            value: text,
            excludeSemantics: true,
            onTap: enabled ? _toggle : null,
            child: FocusableActionDetector(
              enabled: enabled,
              mouseCursor: enabled
                  ? SystemMouseCursors.click
                  : MouseCursor.defer,
              onShowHoverHighlight: (value) => setState(() => _hovered = value),
              onShowFocusHighlight: (value) => setState(() => _focused = value),
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    _toggle();
                    return null;
                  },
                ),
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? _toggle : null,
                child: CompositedTransformTarget(link: _link, child: box),
              ),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(helper, style: AppTypography.b3.copyWith(color: helperColor)),
          ],
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeMenu,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: _flip ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor: _flip ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset(
            0,
            _flip ? -AppDropdown.menuOffset : AppDropdown.menuOffset,
          ),
          child: SizedBox(
            width: _width,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: AppDropdown.menuMaxHeight,
              ),
              child: AppDropdownMenu<T>(
                items: widget.items,
                value: widget.value,
                onSelected: _select,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
