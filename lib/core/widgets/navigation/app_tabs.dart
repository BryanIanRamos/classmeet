import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The looks of [AppTabs]. The DS Tab sheet (Figma 5248:10271) only has the
/// pill-shaped [segment] look; the two others come from the screens.
enum AppTabsStyle {
  /// DS "Tab (Item)": 40 high, radius 20, 12 padding, 14/16 SemiBold label,
  /// Sage-500 fill when selected and Sage-500 text otherwise. Tabs hug their
  /// label and touch each other.
  segment(
    height: 40,
    radius: AppRadii.lg,
    horizontalPadding: AppSpacing.sm,
    gap: AppSpacing.none,
    textStyle: AppTypography.buttonMedium,
  ),

  /// "My Materials / My Classes" (screens 92, 93): 48 high, 16/24 Medium
  /// label and a 4 high Sage-500 line under the selected tab.
  underline(
    height: 48,
    radius: AppRadii.xs,
    horizontalPadding: AppSpacing.sm,
    gap: AppSpacing.none,
    textStyle: AppTypography.b2,
  ),

  /// Reader modes "Read / Visual / Listen / Summary" (screens 87 to 89): 32
  /// high pills, radius 16, 16/24 Medium label; selected is a Sage-500 fill,
  /// the others a grey-100 fill.
  pill(
    height: 32,
    radius: AppRadii.md,
    horizontalPadding: AppSpacing.xs,
    gap: AppSpacing.xs,
    textStyle: AppTypography.b2,
  );

  const AppTabsStyle({
    required this.height,
    required this.radius,
    required this.horizontalPadding,
    required this.gap,
    required this.textStyle,
  });

  /// Height of one tab.
  final double height;

  /// Corner radius of the tab (and of its focus ring).
  final double radius;

  /// Padding between the tab edge and its content.
  final double horizontalPadding;

  /// Space between two tabs.
  final double gap;

  /// Style of the label.
  final TextStyle textStyle;
}

/// One tab of [AppTabs].
@immutable
class AppTabItem {
  const AppTabItem({
    required this.label,
    this.icon,
    this.count,
    this.enabled = true,
    this.statesController,
  });

  final String label;

  /// Leading icon (DS "Icon Left").
  final IconData? icon;

  /// Small counter shown after the label.
  final int? count;

  /// False disables only this tab (DS "Disabled").
  final bool enabled;

  /// Extra states (hovered, focused) to show without interaction (galleries,
  /// goldens).
  final WidgetStatesController? statesController;
}

/// The ClassMeet tab bar: a row of tabs of which exactly one is selected.
///
/// Pick the look with [style]: [AppTabsStyle.underline] for the Study tabs,
/// [AppTabsStyle.pill] for the reader modes and [AppTabsStyle.segment] for
/// the DS component. By default the tabs share the width equally; with
/// [scrollable] they hug their labels and scroll sideways, so five tabs fit
/// at 360dp either way.
///
/// Colours come from the screens: the kit blue is Sage-500, the hover tint
/// Sage-50 and the focus ring Sage-300. To show a hover or focus state without
/// interaction, pass [AppTabItem.statesController].
class AppTabs extends StatelessWidget {
  const AppTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.style = AppTabsStyle.underline,
    this.scrollable = false,
  }) : assert(selectedIndex >= 0 && selectedIndex < tabs.length);

  /// Width of the selected line of [AppTabsStyle.underline]: 4 high, radius 64
  /// (Navbar Top item, screen 92).
  static const indicatorHeight = 4.0;

  /// Width of the focus ring.
  static const focusRingWidth = 3.0;

  /// Size of the tab icons (DS 24).
  static const iconSize = 24.0;

  /// Key prefix of the tab boxes: `ValueKey('AppTabs.item.<index>')`.
  static ValueKey<String> itemKey(int index) =>
      ValueKey<String>('AppTabs.item.$index');

  /// Key prefix of the underline: `ValueKey('AppTabs.indicator.<index>')`.
  static ValueKey<String> indicatorKey(int index) =>
      ValueKey<String>('AppTabs.indicator.$index');

  final List<AppTabItem> tabs;
  final int selectedIndex;

  /// Called with the tapped index. Null disables the whole bar.
  final ValueChanged<int>? onChanged;

  final AppTabsStyle style;

  /// Tabs hug their label and the bar scrolls, instead of equal widths.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      if (i > 0 && style.gap > 0) items.add(SizedBox(width: style.gap));
      final tab = _Tab(
        key: itemKey(i),
        index: i,
        item: tabs[i],
        style: style,
        selected: i == selectedIndex,
        enabled: onChanged != null && tabs[i].enabled,
        onTap: () => onChanged?.call(i),
      );
      items.add(scrollable ? tab : Expanded(child: tab));
    }
    final row = Row(
      mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: items,
    );
    return SizedBox(
      height: style.height,
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: row,
            )
          : row,
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    super.key,
    required this.index,
    required this.item,
    required this.style,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final AppTabItem item;
  final AppTabsStyle style;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.item.statesController?.addListener(_onStates);
  }

  @override
  void didUpdateWidget(_Tab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.statesController != widget.item.statesController) {
      oldWidget.item.statesController?.removeListener(_onStates);
      widget.item.statesController?.addListener(_onStates);
    }
  }

  @override
  void dispose() {
    widget.item.statesController?.removeListener(_onStates);
    super.dispose();
  }

  void _onStates() => setState(() {});

  bool _has(WidgetState state, bool real) =>
      real || (widget.item.statesController?.value.contains(state) ?? false);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = widget.style;
    final enabled = widget.enabled;
    final selected = widget.selected;
    final hovered = enabled && _has(WidgetState.hovered, _hovered);
    final focused = enabled && _has(WidgetState.focused, _focused);
    final foreground = _foreground(colors, enabled, selected, hovered);

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.item.icon case final icon?) ...[
          Icon(icon, size: AppTabs.iconSize, color: foreground),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Flexible(
          child: Text(
            widget.item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.textStyle.copyWith(color: foreground),
          ),
        ),
        if (widget.item.count case final count?) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text('$count', style: AppTypography.c2.copyWith(color: foreground)),
        ],
      ],
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: style.horizontalPadding),
      child: Center(widthFactor: 1, child: label),
    );

    Widget body;
    if (style == AppTabsStyle.underline) {
      body = Column(
        children: [
          Expanded(child: content),
          SizedBox(
            height: AppTabs.indicatorHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: selected
                  ? DecoratedBox(
                      key: AppTabs.indicatorKey(widget.index),
                      decoration: const BoxDecoration(
                        color: AppColors.sage500,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadii.xl5),
                        ),
                      ),
                      child: const SizedBox.expand(),
                    )
                  : null,
            ),
          ),
        ],
      );
    } else {
      body = content;
    }

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: _fill(selected, enabled, hovered, focused),
        borderRadius: BorderRadius.all(Radius.circular(style.radius)),
        border: focused && style != AppTabsStyle.segment
            ? Border.all(
                color: AppColors.sage300,
                width: AppTabs.focusRingWidth,
              )
            : null,
        boxShadow: focused && style == AppTabsStyle.segment
            ? const [
                BoxShadow(
                  color: AppColors.sage300,
                  spreadRadius: AppTabs.focusRingWidth,
                ),
              ]
            : null,
      ),
      child: body,
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: widget.item.label,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onTap : null,
          child: SizedBox(height: style.height, child: decorated),
        ),
      ),
    );
  }

  Color _fill(bool selected, bool enabled, bool hovered, bool focused) {
    switch (widget.style) {
      case AppTabsStyle.segment:
        if (selected && enabled) return AppColors.sage500;
        if (focused) return AppColors.white;
        if (hovered) return AppColors.sage50;
        return Colors.transparent;
      case AppTabsStyle.underline:
        return hovered && !selected ? AppColors.grey50 : Colors.transparent;
      case AppTabsStyle.pill:
        if (!enabled) return AppColors.grey100;
        if (selected) return hovered ? AppColors.sage700 : AppColors.sage500;
        return hovered ? AppColors.grey200 : AppColors.grey100;
    }
  }

  Color _foreground(
    AppSemanticColors colors,
    bool enabled,
    bool selected,
    bool hovered,
  ) {
    if (!enabled) return colors.textGrey;
    switch (widget.style) {
      case AppTabsStyle.segment:
        return selected ? colors.textPrimaryWhite : colors.textSecondaryAccent;
      case AppTabsStyle.underline:
        if (selected) return colors.textSecondaryAccent;
        return hovered ? colors.textPrimary : colors.textSecondary;
      case AppTabsStyle.pill:
        return selected ? colors.textPrimaryWhite : colors.textSecondary;
    }
  }
}
