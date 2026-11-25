import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/section_header.dart';

/// "Recent searches" with "Clear all" and one clock row per entry (12),
/// closed by a Grey-300 line.
class SearchRecentSection extends StatelessWidget {
  const SearchRecentSection({
    super.key,
    required this.recents,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> recents;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  static const _iconSize = 16.0;
  static const _rowHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey300)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Recent searches',
              actionLabel: 'Clear all',
              onActionTap: onClear,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (var i = 0; i < recents.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.xs),
              _row(colors, recents[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(AppSemanticColors colors, String recent) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(recent),
      child: SizedBox(
        height: _rowHeight,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            children: [
              Icon(AppIcons.clock7, size: _iconSize, color: colors.iconGrey),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  recent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.c1.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
