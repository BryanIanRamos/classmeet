import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// One destination of the bottom nav: its icon and label. The enum index is
/// the shell branch index.
enum AppBottomNavTab {
  home(AppIcons.house, 'Home'),
  study(AppIcons.bookOpen, 'Study'),
  play(AppIcons.gamepad2, 'Play'),
  friends(AppIcons.users, 'Friends');

  const AppBottomNavTab(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// The ClassMeet bottom bar (DS "Navbar Bottom" 5248:1725, style "Line
/// Selector + Icon + Text"; geometry from the screens, frame 8 and 119).
///
/// Five slots: Home, Study, the centre "+" (Floating Action Button style),
/// Play, Friends. The tabs map to branch indexes 0..3 via [currentIndex] and
/// [onTabSelected]. The selected tab shows a plume-300 line selector and an
/// accent label; the others are disabled-grey. While [createOpen], the "+"
/// shows a "x".
///
/// The bar is 58dp of items plus a 12dp gap and a bottom area of 24dp (the
/// home indicator), or the device's bottom inset if that is larger. Fill
/// grey-50, 1dp grey-100 top stroke, 32dp top radius.
///
/// INC: the DS sheet shows 78x48 items with a full-width selector, a kit blue
/// and Inter labels; the screens win (78x58, 30dp selector, Plus Jakarta
/// Sans, plume). Screen 119 draws the open "x" button in sage-500; frame 8
/// uses plume-500 for the "+", and so does this widget in both states.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.createOpen,
    required this.onCreatePressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool createOpen;
  final VoidCallback onCreatePressed;

  /// Height of the item row.
  static const itemHeight = 58.0;

  /// Widest an item gets (the screens' 78); the row is centred.
  static const itemMaxWidth = 78.0;
  static const slotCount = 5;

  /// Gap between the item row and the home-indicator area.
  static const indicatorGap = AppSpacing.sm;

  /// Height of the home-indicator area when the device has no bottom inset.
  static const indicatorArea = AppSpacing.xl;

  /// Line selector above the selected item.
  static const selectorWidth = 30.0;
  static const selectorHeight = 4.0;

  /// Space between the selector and the icon block.
  static const selectorGap = 10.0;

  /// Icon block of an item (icon 24 over the label).
  static const blockHeight = 44.0;
  static const iconSize = 24.0;

  /// Diameter of the centre action button.
  static const fabSize = 44.0;

  /// Top stroke width (added above the content).
  static const borderWidth = 1.0;

  /// Radius of the top corners.
  static const topRadius = AppRadii.xxl;

  /// Slot index of the centre "+".
  static const createSlot = 2;

  /// Branch index of a slot (the "+" has none).
  static int _branch(int slot) => slot < createSlot ? slot : slot - 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceLightGrey,
        border: const Border(top: BorderSide(color: AppColors.grey100)),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: borderWidth,
          bottom: indicatorGap + math.max(inset, indicatorArea),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: itemMaxWidth * slotCount,
            ),
            child: SizedBox(
              height: itemHeight,
              child: Row(
                children: [
                  for (var slot = 0; slot < slotCount; slot++)
                    Expanded(
                      child: slot == createSlot
                          ? _CreateButton(
                              open: createOpen,
                              onPressed: onCreatePressed,
                            )
                          : _TabItem(
                              tab: AppBottomNavTab.values[_branch(slot)],
                              selected: currentIndex == _branch(slot),
                              onTap: () => onTabSelected(_branch(slot)),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = selected ? colors.iconAccent : colors.iconDisabled;
    final textColor = selected ? colors.textAccent : colors.textDisabled;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(
              width: AppBottomNav.selectorWidth,
              height: AppBottomNav.selectorHeight,
              child: DecoratedBox(
                key: ValueKey('nav-selector-${tab.name}'),
                decoration: BoxDecoration(
                  color: selected ? AppColors.plume300 : Colors.transparent,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.xl5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppBottomNav.selectorGap),
            SizedBox(
              height: AppBottomNav.blockHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tab.icon, size: AppBottomNav.iconSize, color: iconColor),
                  Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: AppTypography.c3Medium.copyWith(color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.open, required this.onPressed});

  final bool open;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: open ? 'Close create menu' : 'Create',
      excludeSemantics: true,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Center(
          child: DecoratedBox(
            // Frame 8 fills "+" Plume-500; frames 119/120 fill the open "✕"
            // Sage-500.
            decoration: BoxDecoration(
              color: open ? AppColors.sage500 : AppColors.plume500,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: AppBottomNav.fabSize,
              height: AppBottomNav.fabSize,
              child: Icon(
                open ? AppIcons.x : AppIcons.plus,
                key: ValueKey(open ? 'nav-create-close' : 'nav-create-open'),
                size: AppBottomNav.iconSize,
                color: colors.iconWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
