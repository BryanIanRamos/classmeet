import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/step_scaffold.dart';
import '../../../../core/widgets/selection/selectable_card.dart';
import '../../../../data/models/onboarding_prefs.dart';
import '../../application/onboarding_controller.dart';

/// Onboarding step 3 of 4: "Your learning preferences" (frame 98).
///
/// Six study-method cards, at most three chosen. Once three are chosen the
/// other cards keep their look and their taps are ignored by the controller
/// (rather than turning grey, which the design doesn't show). The methods are
/// a fixed enum, so there is no empty state; a failed load shows the error
/// state with a retry.
class LearningPreferencesScreen extends ConsumerWidget {
  const LearningPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(onboardingControllerProvider);
    final chosen = prefs.value?.studyMethods.isNotEmpty ?? false;
    return StepScaffold(
      title: 'Your learning preferences',
      step: 3,
      totalSteps: 4,
      heading: 'How do you like to study?',
      subheading:
          "Choose the methods you enjoy. We'll tailor your study sessions to you.",
      primaryLabel: 'Continue',
      onPrimary: chosen ? () => context.push(Routes.onboardingRoutine) : null,
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      child: switch (prefs) {
        AsyncData(:final value) => _MethodList(prefs: value),
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

/// Card icons, by method (the design's `li:*` names).
IconData _iconOf(StudyMethod method) => switch (method) {
  StudyMethod.flashcards => AppIcons.layers,
  StudyMethod.practiceQuizzes => AppIcons.clipboardCheck,
  StudyMethod.studyParty => AppIcons.gamepad2,
  StudyMethod.visualSummaries => AppIcons.network,
  StudyMethod.readingSummaries => AppIcons.bookOpen,
  StudyMethod.stepByStep => AppIcons.alignLeft,
};

class _MethodList extends ConsumerWidget {
  const _MethodList({required this.prefs});

  final OnboardingPrefs prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Preferred study methods',
                style: AppTypography.b2.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${prefs.studyMethods.length} of '
              '${OnboardingPrefs.maxStudyMethods} selected',
              style: AppTypography.c1.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        for (final method in StudyMethod.values) ...[
          const SizedBox(height: AppSpacing.xs),
          SelectableCard(
            indicatorColor: AppColors.plume500,
            indicatorFill: AppColors.plume50,
            title: method.label,
            description: method.caption,
            leadingIcon: _iconOf(method),
            selected: prefs.studyMethods.contains(method),
            onTap: () => controller.toggleStudyMethod(method),
          ),
        ],
      ],
    );
  }
}
