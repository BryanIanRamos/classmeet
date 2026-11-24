import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/step_scaffold.dart';
import '../../../../core/widgets/selection/app_chip.dart';
import '../../../../data/models/catalog.dart';
import '../../application/onboarding_controller.dart';
import '../widgets/add_subject_sheet.dart';

/// Id prefix of subjects the user typed in (provisional, GAP-22).
const customSubjectPrefix = 'custom:';

/// Onboarding step 2 of 4: "Your study subjects" (frame 97).
///
/// Subjects are neutral pill chips that fill sage when picked (the design
/// shows no check mark, so these are filter chips, not multi-select). The
/// "Add another subject" row opens a provisional sheet (GAP-22); added
/// subjects join the chips, already selected. Continue needs one subject.
class StudySubjectsScreen extends ConsumerStatefulWidget {
  const StudySubjectsScreen({super.key});

  @override
  ConsumerState<StudySubjectsScreen> createState() =>
      _StudySubjectsScreenState();
}

class _StudySubjectsScreenState extends ConsumerState<StudySubjectsScreen> {
  /// Names of the subjects added by hand, in the order added.
  final _custom = <String>[];

  Future<void> _add() async {
    final name = await showAddSubjectSheet(context);
    if (name == null || name.isEmpty || !mounted) return;
    final id = '$customSubjectPrefix$name';
    final selected =
        ref.read(onboardingControllerProvider).value?.subjectIds ?? const {};
    if (!_custom.contains(name)) setState(() => _custom.add(name));
    if (!selected.contains(id)) {
      ref.read(onboardingControllerProvider.notifier).toggleSubject(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(onboardingControllerProvider);
    final subjects = ref.watch(subjectsProvider(prefs.value?.programId));
    final selected = prefs.value?.subjectIds ?? const <String>{};
    return StepScaffold(
      title: 'Your study subjects',
      step: 2,
      totalSteps: 4,
      heading: 'What are you studying?',
      subheading: 'Pick your subjects to personalize your learning experience.',
      primaryLabel: 'Continue',
      ctaLayout: StepCtaLayout.inline,
      onPrimary: selected.isNotEmpty
          ? () => context.push(Routes.onboardingPreferences)
          : null,
      // Navigator (not go_router's context.pop) so the screen also builds
      // without a router, as in the render harness.
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      child: switch ((prefs, subjects)) {
        (AsyncError(), _) => ErrorState(
          onRetry: () => ref.invalidate(onboardingControllerProvider),
        ),
        (_, AsyncError()) => ErrorState(
          onRetry: () => ref.invalidate(subjectsProvider),
        ),
        (AsyncData(), AsyncData(value: final list)) => _SubjectsBody(
          subjects: list,
          custom: _custom,
          selected: selected,
          onToggle: ref
              .read(onboardingControllerProvider.notifier)
              .toggleSubject,
          onAdd: _add,
        ),
        _ => const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: AppLoader()),
        ),
      },
    );
  }
}

class _SubjectsBody extends StatelessWidget {
  const _SubjectsBody({
    required this.subjects,
    required this.custom,
    required this.selected,
    required this.onToggle,
    required this.onAdd,
  });

  final List<Subject> subjects;
  final List<String> custom;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onAdd;

  /// Gaps between the chips (Frame 7 wraps them with 8 / 12).
  static const _chipGap = AppSpacing.xs;
  static const _runGap = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final s in subjects) (id: s.id, name: s.name),
      for (final name in custom) (id: '$customSubjectPrefix$name', name: name),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.md,
          ),
          child: Text(
            'Please select all that apply',
            style: AppTypography.b3.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        if (entries.isEmpty)
          const EmptyState(
            title: 'No subjects yet',
            message: 'Add the subjects you study to continue.',
          )
        else
          Wrap(
            spacing: _chipGap,
            runSpacing: _runGap,
            children: [
              for (final e in entries)
                AppChip.filter(
                  label: e.name,
                  selected: selected.contains(e.id),
                  onSelected: (_) => onToggle(e.id),
                  style: AppChipStyle.neutral,
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.md),
        _AddSubjectRow(onTap: onAdd),
      ],
    );
  }
}

/// The "+ Add another subject" row: a Large input box (48 high, radius 12,
/// white with a 1.5 Grey-200 border), as in spec 97.
class _AddSubjectRow extends StatelessWidget {
  const _AddSubjectRow({required this.onTap});

  final VoidCallback onTap;

  static const _height = 48.0;
  static const _strokeWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    return Semantics(
      button: true,
      label: 'Add another subject',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.sm)),
            border: Border.all(color: AppColors.grey200, width: _strokeWidth),
          ),
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Icon(AppIcons.plus, size: AppSpacing.xl, color: color),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Add another subject',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.b1.copyWith(color: color),
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
