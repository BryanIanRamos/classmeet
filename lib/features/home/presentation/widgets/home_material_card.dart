import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/widgets/display/app_list_row.dart';
import '../../../../core/widgets/feedback/app_progress_bar.dart';
import '../../../../data/models/material.dart';
import '../../application/home_providers.dart';
import 'home_goal_card.dart';
import 'home_meta_line.dart';

/// The "Pick up where you left off" card (frame 8): a started material,
/// "1 module left · 40% read", and its reading progress.
class HomeMaterialCard extends StatelessWidget {
  const HomeMaterialCard({
    super.key,
    required this.material,
    required this.onTap,
  });

  final StudyMaterial material;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final left = material.modulesLeft;
    final percent = (material.fraction * 100).round();
    return AppListRow(
      leadingIcon: AppIcons.fileText,
      title: material.title,
      subtitleWidget: HomeMetaLine(
        parts: [
          TextSpan(text: '$left ${countLabel(left, 'module')} left'),
          TextSpan(text: '$percent% read'),
        ],
      ),
      showChevron: true,
      onTap: onTap,
      bottom: AppProgressBar(
        value: material.fraction,
        segments: HomeGoalCard.segments,
        label: '$percent%',
      ),
    );
  }
}
