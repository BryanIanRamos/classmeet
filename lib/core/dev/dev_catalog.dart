import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/display/app_badge.dart';
import '../widgets/display/app_list_row.dart';
import '../widgets/display/section_header.dart';
import '../widgets/navigation/app_navbar_top.dart';
import 'frames.dart';

/// Debug-only catalog of every Figma frame (`/dev`): tap a row to open the
/// screen that shows it. Also links the token and widget galleries and lists
/// the paths that still show "Coming soon".
class DevCatalog extends StatelessWidget {
  const DevCatalog({super.key});

  /// Paths that open a "Coming soon" screen because Figma has no frame yet.
  static final gapPaths = <String>[
    Routes.carsuSignIn,
    Routes.terms,
    Routes.privacy,
    Routes.streak,
    Routes.studyPlan,
    Routes.rewardsHistory,
    Routes.studyTool('flashcards'),
    Routes.createTool('flashcards'),
    Routes.quizBattle,
    Routes.leaderboard,
    Routes.myQuizzes,
    Routes.friends,
    Routes.profile,
    Routes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppNavbarTop(
              title: 'Dev catalog',
              onBack: context.canPop() ? context.pop : null,
              showBottomBorder: true,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const SectionHeader(title: 'Galleries'),
                  const _Link(title: 'Tokens', location: '/dev/tokens'),
                  const _Link(title: 'Widgets', location: '/dev/widgets'),
                  for (final section in DevSection.values) ...[
                    const SizedBox(height: AppSpacing.md),
                    SectionHeader(title: section.title),
                    for (final frame in devFrames.where(
                      (f) => f.section == section,
                    ))
                      _Link(
                        title: '${frame.number}  ${frame.title}',
                        location: frame.location,
                        state: frame.state,
                        sheet: frame.sheet,
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  const SectionHeader(
                    title: 'Gaps',
                    subtitle: 'No Figma frame yet; these show Coming soon.',
                  ),
                  for (final path in gapPaths)
                    _Link(title: path, location: path),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.title,
    required this.location,
    this.state,
    this.sheet,
  });

  final String title;
  final String location;
  final String? state;
  final String? sheet;

  @override
  Widget build(BuildContext context) {
    return AppListRow(
      style: AppListRowStyle.plain,
      title: title,
      subtitle: location == title ? null : location,
      trailing: state != null
          ? const AppBadge(label: 'state', tone: AppBadgeTone.info)
          : sheet != null
          ? const AppBadge(label: 'sheet', tone: AppBadgeTone.warning)
          : null,
      showChevron: true,
      showDivider: true,
      onTap: () => context.push(location),
    );
  }
}
