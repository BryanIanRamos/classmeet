import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/step_scaffold.dart';
import '../../../../core/widgets/selection/app_chip.dart';
import '../../../../core/widgets/selection/selectable_card.dart';
import '../../../../data/models/onboarding_prefs.dart';
import '../../application/onboarding_controller.dart';

/// Onboarding step 4 of 4: "Your study routine" (frame 99).
///
/// A 2x2 grid of radio [SelectableCard]s for the daily goal, then three rows
/// of neutral choice chips (frequency, reminder time, learning language, which
/// moved here from step 96, INC-3). Continue needs all four answers; it saves
/// through the controller, marks the session ready and goes to Home with `go`,
/// so back cannot return to onboarding. Reminders need notification
/// permission later (GAP-05, task 10.6).
///
/// There is no empty state: every option is a fixed enum.
class StudyRoutineScreen extends ConsumerStatefulWidget {
  const StudyRoutineScreen({super.key});

  @override
  ConsumerState<StudyRoutineScreen> createState() => _StudyRoutineScreenState();
}

class _StudyRoutineScreenState extends ConsumerState<StudyRoutineScreen> {
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).finish();
      if (mounted) context.go(Routes.home);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(onboardingControllerProvider);
    final complete = prefs.value?.routineComplete ?? false;
    return StepScaffold(
      title: 'Your study routine',
      step: 4,
      totalSteps: 4,
      heading: "What's your study routine?",
      subheading:
          'Choose a study goal and schedule that work for you. '
          'You can always change them later.',
      primaryLabel: 'Continue',
      ctaLayout: StepCtaLayout.inline,
      onPrimary: complete && !_saving ? _finish : null,
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      child: switch (prefs) {
        AsyncData(:final value) => _RoutineForm(prefs: value),
        AsyncError() => ErrorState(
          onRetry: () => ref.invalidate(onboardingControllerProvider),
        ),
        _ => const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: AppLoader()),
        ),
      },
    );
  }
}

extension on OnboardingPrefs {
  bool get routineComplete =>
      dailyGoal != null &&
      frequency != null &&
      reminderTime != null &&
      language != null;
}

class _RoutineForm extends ConsumerWidget {
  const _RoutineForm({required this.prefs});

  final OnboardingPrefs prefs;

  /// Gap between goal cards and between chips in a row.
  static const _cardGap = AppSpacing.xs;
  static const _chipGap = AppSpacing.sm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    const goals = DailyGoal.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          label: "What's your daily study goal?",
          child: Column(
            children: [
              for (var row = 0; row < goals.length; row += 2) ...[
                if (row > 0) const SizedBox(height: _cardGap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = row; i < row + 2; i++) ...[
                        if (i > row) const SizedBox(width: _cardGap),
                        Expanded(
                          child: SelectableCard(
                            title: goals[i].label,
                            description: goals[i].caption,
                            selected: prefs.dailyGoal == goals[i],
                            onTap: () => controller.selectDailyGoal(goals[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _Section(
          label: 'How often do you want to study?',
          child: _chips(
            StudyFrequency.values,
            (v) => v.label,
            prefs.frequency,
            controller.selectFrequency,
          ),
        ),
        _Section(
          label: 'When should we remind you?',
          child: _chips(
            ReminderTime.values,
            (v) => v.label,
            prefs.reminderTime,
            controller.selectReminderTime,
          ),
        ),
        _Section(
          label: 'Preferred learning language',
          child: _chips(
            LearningLanguage.values,
            (v) => v.label,
            prefs.language,
            controller.selectLanguage,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            'You can change your study preferences anytime.',
            textAlign: TextAlign.center,
            style: AppTypography.b3.copyWith(color: AppColors.grey500),
          ),
        ),
      ],
    );
  }

  Widget _chips<T>(
    List<T> values,
    String Function(T) label,
    T? selected,
    void Function(T) onSelect,
  ) {
    return Wrap(
      spacing: _chipGap,
      runSpacing: AppSpacing.xs,
      children: [
        for (final value in values)
          AppChip.choice(
            label: label(value),
            selected: selected == value,
            onSelected: (_) => onSelect(value),
            style: AppChipStyle.neutral,
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTypography.b2.copyWith(color: context.colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}
