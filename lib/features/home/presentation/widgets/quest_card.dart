import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/app_list_row.dart';
import '../../../../core/widgets/display/illustrated_card.dart';
import '../../../../data/models/quest.dart';
import '../../application/home_providers.dart';
import '../home_format.dart';
import 'home_meta_line.dart';
import 'talon_chip.dart';
import 'talon_progress_bar.dart';

/// Colours, icon and copy of a quest card, by quest kind (frame 14).
enum QuestCardLook {
  /// "Daily General Knowledge Quiz": Sage-50 fill, Sage-300 border, Sage-700
  /// title and icon, Sage-300 bar track. Its content is 368 wide, 4 wider on
  /// each side than the other two cards' (spec 14, "Frame 1300": 13 from the
  /// card's edge, not 17).
  daily(
    icon: AppIcons.brain,
    fill: AppColors.sage50,
    border: AppColors.sage300,
    accent: AppColors.sage700,
    tone: AppButtonTone.sage,
    inset: AppSpacing.sm,
    hasProgress: true,
    hasStatusRow: true,
  ),

  /// "Study Streak Milestone I": Sage-50 fill, Plume-300 border, Plume-500
  /// title, icon, bar and note.
  milestone(
    icon: AppIcons.flame,
    fill: AppColors.sage50,
    border: AppColors.plume300,
    accent: AppColors.plume500,
    tone: AppButtonTone.plume,
    inset: AppSpacing.md,
    hasProgress: true,
    note: 'Study a little each day to reach your milestone.',
    noteColor: AppColors.plume500,
  ),

  /// "Weekly Survey": Sky-50 fill, Sky-300 border, Sky-900 title and icon,
  /// Sky-700 note. No progress bar. The design repeats the milestone's
  /// sentence here, a copy-paste slip (INC); this note is provisional.
  survey(
    icon: AppIcons.filePen,
    fill: AppColors.sky50,
    border: AppColors.sky300,
    accent: AppColors.sky900,
    tone: AppButtonTone.sky,
    inset: AppSpacing.md,
    note: 'Share how your study week went.',
    noteColor: AppColors.sky700,
  );

  const QuestCardLook({
    required this.icon,
    required this.fill,
    required this.border,
    required this.accent,
    required this.tone,
    required this.inset,
    this.hasProgress = false,
    this.hasStatusRow = false,
    this.note,
    this.noteColor,
  });

  static QuestCardLook of(QuestKind kind) => switch (kind) {
    QuestKind.daily => daily,
    QuestKind.milestone => milestone,
    QuestKind.survey => survey,
  };

  final IconData icon;
  final Color fill;
  final Color border;

  /// Title and icon colour, and the fill of the progress bar.
  final Color accent;

  /// The card's button colour family.
  final AppButtonTone tone;

  /// Space between the border and the content, left and right (Figma
  /// padding; the 1 dp border comes on top).
  final double inset;

  /// "6 of 7 days completed" and a bar under the header.
  final bool hasProgress;

  /// "Completed today" and when the quest resets.
  final bool hasStatusRow;

  /// The sentence above the button, and its colour.
  final String? note;
  final Color? noteColor;

  /// The bar's track: the card's border colour in the design.
  Color get barTrack => border;
}

/// A quest card of Talon credits (frame 14): an icon, the title and its
/// subtitle, a "+5" reward chip, then (by kind) a progress bar, a status
/// row and a note, and a full-width button.
///
/// The three designed cards are the claimed daily quiz ("6 of 7 days
/// completed", the bar, "Completed today · Resets tomorrow", "Reward
/// claimed"), the locked milestone ("3 of 7 days completed", the bar, the
/// note, "Complete 7 days to unlock") and the open survey ("1 minute ·
/// Available until Sunday", the note, "Answer survey"). All three are
/// 16 apart on the screen, 198, 198 and 162 tall on the 428 frame.
///
/// The button follows the quest's status:
/// * claimed: "Reward claimed", disabled but in the card's colours;
/// * locked: "Complete N days to unlock", disabled on Grey-50 (a milestone
///   that is not completed reads the same: it has no action of its own);
/// * completed: "Claim reward" (provisional label), which runs [onClaim] and
///   is busy while [claiming];
/// * available: "Answer survey" for the survey and "Take today's quiz"
///   (provisional) for a daily quiz, which run [onOpen].
///
/// The card art (a wave over the fill, manual export 1.8) arrives as [art].
/// Until then the card is its plain fill.
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.onOpen,
    required this.onClaim,
    this.claiming = false,
    this.art,
  });

  final Quest quest;

  /// Opens the quiz or the survey (the available button).
  final VoidCallback onOpen;

  /// Claims a completed quest's reward.
  final VoidCallback onClaim;

  /// The claim is running: the button stays "Claim reward" but ignores taps.
  final bool claiming;

  /// Text-free card art (manual export 1.8); null shows the plain fill.
  final AppImage? art;

  /// Icon slot and minimum height of the header ("Navbar Top (Left Item)"
  /// 48×48).
  static const iconSlot = 48.0;

  /// [IllustratedCard] draws its border over the card's edge without taking
  /// layout space; Figma lays the content out 1 + 16 (1 + 12 on the daily
  /// quiz) from the edge, so the border is added to the padding.
  static const _border = IllustratedCard.borderWidth;

  /// Space between the blocks of the card (spec 14, "Frame 1300": gap 12).
  static const _blockGap = AppSpacing.sm;

  /// Space above and below the bar (spec 14, "Frame 1147": 24 tall around an
  /// 8 bar).
  static const _barPadding = AppSpacing.xs;

  /// Space between the title block and the chip.
  static const _chipGap = AppSpacing.xs;

  /// A long title wraps to two lines (on narrow screens) before it is cut.
  static const _titleLines = 2;

  static const _statusIconSize = 16.0;

  /// Gap between the check and "Completed today" (spec 14, "Frame 1194").
  static const _statusGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final look = QuestCardLook.of(quest.kind);
    final colors = context.colors;
    final action = _action();
    final status = look.hasStatusRow ? _status(colors) : null;
    final blocks = <Widget>[
      _header(look, colors),
      if (look.hasProgress)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: _barPadding),
          child: TalonProgressBar(
            value: quest.fraction,
            color: look.accent,
            trackColor: look.barTrack,
          ),
        ),
      ?status,
      if (look.note case final note?)
        Text(note, style: AppTypography.c1.copyWith(color: look.noteColor)),
      AppButton(
        label: action.label,
        onPressed: action.onPressed,
        size: AppButtonSize.medium,
        tone: look.tone,
        expand: true,
        disabledLook: action.disabledLook,
      ),
    ];

    return IllustratedCard(
      art: art,
      color: look.fill,
      borderColor: look.border,
      padding: EdgeInsets.symmetric(
        horizontal: _border + look.inset,
        vertical: _border + AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < blocks.length; i++) ...[
            if (i > 0) const SizedBox(height: _blockGap),
            blocks[i],
          ],
        ],
      ),
    );
  }

  Widget _header(QuestCardLook look, AppSemanticColors colors) {
    final subtitle = _subtitle(colors);
    final reward = quest.rewardTalons;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: iconSlot,
          child: Icon(look.icon, size: AppListRow.iconSize, color: look.accent),
        ),
        const SizedBox(width: AppListRow.leadingGap),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: iconSlot),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  maxLines: _titleLines,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.s1.copyWith(color: look.accent),
                ),
                ?subtitle,
              ],
            ),
          ),
        ),
        const SizedBox(width: _chipGap),
        TalonChip(
          label: '+$reward',
          semanticLabel: '+$reward ${countLabel(reward, 'talon')}',
        ),
      ],
    );
  }

  /// "6 of 7 days completed", or the survey's "1 minute · Available until
  /// Sunday".
  Widget? _subtitle(AppSemanticColors colors) {
    if (quest.kind != QuestKind.survey) {
      final days = countLabel(quest.total, 'day');
      return Text(
        '${quest.done} of ${quest.total} $days completed',
        style: AppTypography.c1.copyWith(color: colors.textSecondary),
      );
    }
    final minutes = quest.durationMinutes;
    final until = quest.availableUntil;
    final parts = [
      if (minutes != null) '$minutes ${countLabel(minutes, 'minute')}',
      if (until != null) availableUntilLabel(until),
    ];
    if (parts.isEmpty) return null;
    // Frame 14 sets the line as one text with plain spaces around the dot,
    // closer than the 4 dp gaps HomeMetaLine puts between its parts.
    return HomeMetaLine(
      parts: [
        TextSpan(
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (i > 0) const TextSpan(text: ' · ', semanticsLabel: ', '),
              TextSpan(text: parts[i]),
            ],
          ],
        ),
      ],
    );
  }

  /// The daily quiz's "Completed today" and reset time, or null when there
  /// is neither to say.
  Widget? _status(AppSemanticColors colors) {
    final done =
        quest.status == QuestStatus.completed ||
        quest.status == QuestStatus.claimed;
    final reset = quest.resetsAt == null
        ? null
        : (done ? 'Resets tomorrow' : 'Resets at midnight');
    if (!done && reset == null) return null;
    final style = AppTypography.c1.copyWith(color: colors.textSecondaryAccent);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (done)
          Expanded(
            child: Row(
              children: [
                Icon(
                  AppIcons.circleCheck,
                  size: _statusIconSize,
                  color: colors.iconSecondaryAccent,
                ),
                const SizedBox(width: _statusGap),
                Flexible(child: Text('Completed today', style: style)),
              ],
            ),
          ),
        if (reset != null)
          Expanded(
            child: Text(reset, textAlign: TextAlign.end, style: style),
          ),
      ],
    );
  }

  ({String label, VoidCallback? onPressed, AppButtonDisabledLook disabledLook})
  _action() {
    final days = countLabel(quest.total, 'day');
    final locked = (
      label: 'Complete ${quest.total} $days to unlock',
      onPressed: null,
      disabledLook: AppButtonDisabledLook.light,
    );
    return switch (quest.status) {
      QuestStatus.claimed => (
        label: 'Reward claimed',
        onPressed: null,
        disabledLook: AppButtonDisabledLook.toned,
      ),
      QuestStatus.completed => (
        label: 'Claim reward',
        onPressed: claiming ? null : onClaim,
        disabledLook: AppButtonDisabledLook.toned,
      ),
      QuestStatus.locked => locked,
      QuestStatus.available => switch (quest.kind) {
        QuestKind.survey => (
          label: 'Answer survey',
          onPressed: onOpen,
          disabledLook: AppButtonDisabledLook.muted,
        ),
        QuestKind.daily => (
          label: "Take today's quiz",
          onPressed: onOpen,
          disabledLook: AppButtonDisabledLook.muted,
        ),
        QuestKind.milestone => locked,
      },
    };
  }
}
