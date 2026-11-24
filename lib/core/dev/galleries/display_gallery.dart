import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../assets/app_images.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/display/app_avatar.dart';
import '../../widgets/display/app_badge.dart';
import '../../widgets/selection/app_chip.dart';

const _labelWidth = 100.0;

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(label, style: AppTypography.b3),
          ),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Every [AppAvatar] type × size, with and without the status dot, laid out
/// like the DS sheet (Figma 5248:1634: one row per type, sizes from XXXL
/// Giant down to Tiny).
class AppAvatarMatrix extends StatelessWidget {
  const AppAvatarMatrix({super.key});

  static final _sizes = AppAvatarSize.values.reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final status in const [true, false]) ...[
          Text(status ? 'With status' : 'No status', style: AppTypography.s2),
          _Row(
            label: 'Image',
            children: [
              for (final size in _sizes)
                AppAvatar.asset(
                  AppImages.avatar,
                  size: size,
                  showStatus: status,
                ),
            ],
          ),
          _Row(
            label: 'Letter',
            children: [
              for (final size in _sizes)
                AppAvatar.letter(letter: 'A', size: size, showStatus: status),
            ],
          ),
          _Row(
            label: 'Icon',
            children: [
              for (final size in _sizes)
                AppAvatar.icon(size: size, showStatus: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Every [AppBadge] style × tone × size, with icons and text and icon-only,
/// laid out like the DS sheet (Figma 5248:1220: tone rows, size columns).
class AppBadgeMatrix extends StatelessWidget {
  const AppBadgeMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in AppBadgeStyle.values) ...[
          Text(style.name, style: AppTypography.s2),
          for (final tone in AppBadgeTone.values)
            _Row(
              label: tone.name,
              children: [
                for (final size in AppBadgeSize.values) ...[
                  AppBadge(
                    label: 'Badge',
                    size: size,
                    tone: tone,
                    style: style,
                    leadingIcon: AppIcons.star,
                    trailingIcon: AppIcons.x,
                  ),
                  AppBadge.icon(
                    icon: AppIcons.star,
                    semanticLabel: 'Star',
                    size: size,
                    tone: tone,
                    style: style,
                  ),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// Every [AppChip] kind × style × state, one row per state.
class AppChipMatrix extends StatelessWidget {
  const AppChipMatrix({super.key});

  static const _states = ['Unselected', 'Selected', 'Disabled', 'Removable'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in AppChipStyle.values) ...[
          Text(style.name, style: AppTypography.s2),
          for (final state in _states)
            _Row(
              label: state,
              children: [
                _chip(AppChipKind.filter, style, state, 'Filter'),
                _chip(AppChipKind.choice, style, state, 'Choice'),
                _chip(AppChipKind.multiSelect, style, state, 'Multi'),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _chip(
    AppChipKind kind,
    AppChipStyle style,
    String state,
    String label,
  ) {
    final selected = state == 'Selected' || state == 'Removable';
    final ValueChanged<bool>? onSelected = state == 'Disabled' ? null : (_) {};
    final VoidCallback? onDeleted = state == 'Removable' ? () {} : null;
    return switch (kind) {
      AppChipKind.filter => AppChip.filter(
        label: label,
        selected: selected,
        onSelected: onSelected,
        style: style,
        onDeleted: onDeleted,
      ),
      AppChipKind.choice => AppChip.choice(
        label: label,
        selected: selected,
        onSelected: onSelected,
        style: style,
        onDeleted: onDeleted,
      ),
      AppChipKind.multiSelect => AppChip.multiSelect(
        label: label,
        selected: selected,
        onSelected: onSelected,
        style: style,
        onDeleted: onDeleted,
      ),
    };
  }
}
