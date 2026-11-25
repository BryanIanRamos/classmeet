import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/app_card.dart';
import '../../../../core/widgets/display/app_list_row.dart';
import '../../../../data/models/quest.dart';
import '../home_format.dart';
import 'home_meta_line.dart';

/// The "Earn more talon credits" card (frame 8): the daily quiz or the
/// weekly survey, its reward and when it resets or closes.
///
/// Built on [AppCard] rather than `AppListRow`: these rows (spec 8,
/// "Frame 1181"/"Frame 1182", 402×82) put the icon in a 48 slot and centre
/// the title and meta line on it, 48 tall, with the chevron at the top; the
/// list row has a 40 slot and a padded subtitle. Home uses short names; the
/// quest titles are the longer frame-14 ones.
class HomeQuestCard extends StatelessWidget {
  const HomeQuestCard({super.key, required this.quest, required this.onTap});

  final Quest quest;
  final VoidCallback onTap;

  /// Icon slot and row height ("Navbar Top (Left Item)" 48×48).
  static const iconSlot = 48.0;

  /// The Home name of a quest: frame 8 shortens the daily quiz and the
  /// survey; anything else keeps its own title.
  static String titleFor(Quest quest) => switch (quest.kind) {
    QuestKind.daily => 'General Knowledge Quiz',
    QuestKind.survey => 'Weekly Survey',
    QuestKind.milestone => quest.title,
  };

  static IconData iconFor(QuestKind kind) => switch (kind) {
    QuestKind.daily => AppIcons.brain,
    QuestKind.survey => AppIcons.filePenLine,
    QuestKind.milestone => AppIcons.flame,
  };

  /// "Resets at midnight", "Available until Sunday", or null.
  static String? availabilityFor(Quest quest) {
    if (quest.resetsAt != null) return 'Resets at midnight';
    if (quest.availableUntil case final until?) {
      return availableUntilLabel(until);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = titleFor(quest);
    final note = availabilityFor(quest);
    return AppCard(
      onTap: onTap,
      semanticLabel: title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: iconSlot,
            child: Icon(
              iconFor(quest.kind),
              size: AppListRow.iconSize,
              color: colors.iconBlack,
            ),
          ),
          const SizedBox(width: AppListRow.leadingGap),
          Expanded(
            child: SizedBox(
              height: iconSlot,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.s1.copyWith(color: colors.textPrimary),
                  ),
                  HomeMetaLine(
                    gap: HomeMetaLine.wideGap,
                    parts: [
                      TextSpan(
                        text: '+${quest.rewardTalons} talons',
                        style: AppTypography.c1Bold.copyWith(
                          color: colors.textWarning,
                        ),
                      ),
                      if (note != null) TextSpan(text: note),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            AppIcons.chevronRight,
            size: AppListRow.iconSize,
            color: colors.iconBlack,
          ),
        ],
      ),
    );
  }
}
