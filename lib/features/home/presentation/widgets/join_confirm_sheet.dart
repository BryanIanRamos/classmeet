import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/layout/app_sheet.dart';
import '../../../../data/models/study_class.dart';
import '../../application/join_class_controller.dart';

/// Opens the confirmation sheet for [preview] and returns true when the
/// student should be taken to My Classes: they joined, or chose "Open My
/// Classes" because they were in the class already. Cancelling, dismissing the
/// sheet and a failed join return null or false (the field shows a failure).
Future<bool?> showJoinConfirmSheet(BuildContext context, JoinPreview preview) {
  return showAppSheet<bool>(
    context,
    builder: (_) => JoinConfirmSheet(preview: preview),
  );
}

/// The sheet that confirms a join (provisional, GAP-20: the design stops at
/// the code field). It shows the class that was found, so the student can
/// "check the class name and teacher before confirming", with "Join class"
/// and "Cancel". When the student is in the class already it says so and
/// offers "Open My Classes" instead.
///
/// Built like the other answer sheets (129): the class sits on a Talon-50
/// card, a Talon-900 caption over the Grey-900 name, and the buttons are
/// Large with 12 between them. "Join class" runs the join and closes the
/// sheet when it is done; both buttons wait until then.
class JoinConfirmSheet extends ConsumerStatefulWidget {
  const JoinConfirmSheet({super.key, required this.preview});

  final JoinPreview preview;

  /// Title, note and buttons of the two variants. Provisional copy.
  static const joinTitle = 'Join this class?';
  static const alreadyTitle = "You're already in this class.";
  static const joinNote = "You'll then see the class in My Classes.";
  static const joinLabel = 'Join class';
  static const openLabel = 'Open My Classes';
  static const cancelLabel = 'Cancel';

  @override
  ConsumerState<JoinConfirmSheet> createState() => _JoinConfirmSheetState();
}

class _JoinConfirmSheetState extends ConsumerState<JoinConfirmSheet> {
  /// A button was pressed and the sheet is on its way out. Every press ends
  /// the sheet, and a second tap while it slides away must not pop another
  /// route (the screen under it) or join twice, so later presses do nothing.
  bool _acting = false;

  Future<void> _primary() async {
    if (_acting) return;
    _acting = true;
    if (widget.preview.alreadyJoined) {
      Navigator.pop(context, true);
      return;
    }
    final joined = await ref
        .read(joinClassControllerProvider.notifier)
        .join(widget.preview.code);
    // Dragged away while joining: the screen shows what is left to show.
    if (!mounted) return;
    Navigator.pop(context, joined);
  }

  void _cancel() {
    if (_acting) return;
    _acting = true;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final already = widget.preview.alreadyJoined;
    final joining = ref.watch(
      joinClassControllerProvider.select((s) => s.joining),
    );
    return Padding(
      // Rides above the keyboard if it is still on its way out.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AppSheet(
        title: already
            ? JoinConfirmSheet.alreadyTitle
            : JoinConfirmSheet.joinTitle,
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: already
                  ? JoinConfirmSheet.openLabel
                  : JoinConfirmSheet.joinLabel,
              tone: AppButtonTone.talon,
              expand: true,
              onPressed: joining ? null : _primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: JoinConfirmSheet.cancelLabel,
              style: AppButtonStyle.clear,
              expand: true,
              onPressed: joining ? null : _cancel,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ClassCard(studyClass: widget.preview.studyClass),
            if (!already) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                JoinConfirmSheet.joinNote,
                style: AppTypography.c1.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The class that was found: its code, name and teacher on a Talon-50 card
/// (radius 16, padding 12), as the answer card of sheet 129.
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.studyClass});

  final StudyClass studyClass;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.talon50,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studyClass.code,
              style: AppTypography.c3.copyWith(color: AppColors.talon900),
            ),
            Text(
              studyClass.title,
              style: AppTypography.b2.copyWith(color: colors.textPrimary),
            ),
            Text(
              studyClass.teacher,
              style: AppTypography.c1.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
