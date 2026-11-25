import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/widgets/display/app_list_row.dart';
import '../../../../core/widgets/feedback/app_progress_bar.dart';
import '../../../../data/models/study_plan.dart';
import '../home_format.dart';
import 'home_meta_line.dart';

/// The "Coming up next" card (frame 8): the next deadline, what is left
/// before it ("3 activities left · In 5 days") and its progress (67%).
class HomeGoalCard extends StatelessWidget {
  const HomeGoalCard({
    super.key,
    required this.goal,
    required this.now,
    required this.onTap,
  });

  final PlanGoal goal;

  /// Today, for the "In 5 days" count.
  final DateTime now;
  final VoidCallback onTap;

  /// The Home progress bars have 5 segments (spec 8).
  static const segments = 5;

  @override
  Widget build(BuildContext context) {
    final percent = (goal.fraction * 100).round();
    return AppListRow(
      leadingIcon: AppIcons.calendarDays,
      title: goal.title,
      subtitleWidget: HomeMetaLine(
        parts: [
          TextSpan(text: activitiesLeftLabel(goal.remaining)),
          TextSpan(text: dueLabel(daysUntil(now, goal.dueAt))),
        ],
      ),
      showChevron: true,
      onTap: onTap,
      bottom: AppProgressBar(
        value: goal.fraction,
        segments: segments,
        label: '$percent%',
      ),
    );
  }
}
