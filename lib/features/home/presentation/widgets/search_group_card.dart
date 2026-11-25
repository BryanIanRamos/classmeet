import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/app_card.dart';
import 'home_meta_line.dart';

/// One result group of Search (12): a Grey-50 card with a "Classes" /
/// "Materials" / "People" header, the count in Sage-500, and [rows] split by
/// Grey-300 lines. An [AppCard] with padding 4: its border takes layout
/// space, so the 392-wide rows sit 1 + 4 inside the 402 card (spec 12).
class SearchGroupCard extends StatelessWidget {
  const SearchGroupCard({
    super.key,
    required this.title,
    required this.count,
    required this.rows,
  });

  final String title;
  final int count;
  final List<Widget> rows;

  /// Header padding: 8 above, 16 at the sides.
  static const _headerPadding = EdgeInsets.fromLTRB(
    AppSpacing.md,
    AppSpacing.xs,
    AppSpacing.md,
    AppSpacing.none,
  );

  static const _lineWidth = 1.0;

  /// "1 result", "2 results".
  static String countLabel(int count) =>
      count == 1 ? '1 result' : '$count results';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: _headerPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.s2.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  countLabel(count),
                  style: AppTypography.c1.copyWith(
                    color: colors.textSecondaryAccent,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: _lineWidth,
                thickness: _lineWidth,
                color: AppColors.grey300,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// A result row of Search (12): [leading], the title (S1, black in this
/// frame), a meta line and a chevron. A null [onTap] keeps it static.
///
/// Class and material rows ([SearchResultRow.tile]) are 16 + 48 + 16: the
/// title, 4, and one caption. People rows ([SearchResultRow.person]) frame
/// their meta line with 4 above and below (spec 12 "Frame 1148", pad 4/0),
/// so they are 16 + 56 + 16; their parts sit 4 around a dot, like the Home
/// cards ("BSIT - II · Caraga State University").
class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    super.key,
    required this.leading,
    required this.title,
    required this.meta,
    this.padMeta = false,
    this.onTap,
  });

  /// Class and material row with the icon tile (spec: 40, radius 8).
  factory SearchResultRow.tile({
    Key? key,
    required Color tint,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return SearchResultRow(
      key: key,
      leading: _IconTile(tint: tint),
      title: title,
      meta: [subtitle],
      onTap: onTap,
    );
  }

  /// A person: [avatar], the name, and the program and school.
  factory SearchResultRow.person({
    Key? key,
    required Widget avatar,
    required String name,
    required List<String> meta,
    VoidCallback? onTap,
  }) {
    return SearchResultRow(
      key: key,
      leading: avatar,
      title: name,
      meta: meta,
      padMeta: true,
      onTap: onTap,
    );
  }

  final Widget leading;
  final String title;

  /// The meta line, one or more parts joined by dots.
  final List<String> meta;

  /// Frame the meta line with 4 above and below (people rows).
  final bool padMeta;
  final VoidCallback? onTap;

  static const _gap = 10.0;
  static const _chevronSlot = 40.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final line = HomeMetaLine(parts: [for (final m in meta) TextSpan(text: m)]);
    return Semantics(
      button: onTap != null,
      label: [title, ...meta].join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              leading,
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.s1.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    if (padMeta)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
                        child: line,
                      )
                    else
                      line,
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox.square(
                dimension: _chevronSlot,
                child: Icon(
                  AppIcons.chevronRight,
                  size: _iconSize,
                  color: colors.iconGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.tint});

  final Color tint;

  static const _size = 40.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Icon(
        AppIcons.libraryBig,
        size: _iconSize,
        color: context.colors.iconBlack,
      ),
    );
  }
}
