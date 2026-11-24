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
import '../../../../core/widgets/inputs/app_dropdown.dart';
import '../../../../core/widgets/layout/step_scaffold.dart';
import '../../../../core/widgets/selection/app_chip.dart';
import '../../../../data/models/catalog.dart';
import '../../../../data/models/onboarding_prefs.dart';
import '../../application/onboarding_controller.dart';

/// Onboarding step 1 of 4: "Your academic profile" (frame 96).
///
/// School → College → Program are dependent dropdowns: each opens once the
/// one above has a value, and the next empty one wears the Plume accent, as
/// "Select College" does in the design. A chosen value shows the confirmed
/// look (grey-900 border and a check, like the School field). Year level is
/// a row of neutral choice chips. The design's "Preferred learning language"
/// row is left out: the language is asked in step 99 (INC-3, U-5).
class AcademicProfileScreen extends ConsumerWidget {
  const AcademicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(onboardingControllerProvider);
    final complete = prefs.value?.academicComplete ?? false;
    return StepScaffold(
      title: 'Your academic profile',
      step: 1,
      totalSteps: 4,
      heading: 'Where do you study?',
      subheading: 'Tell us about your school, program, and year level.',
      primaryLabel: 'Continue',
      ctaLayout: StepCtaLayout.inline,
      onPrimary: complete
          ? () => context.push(Routes.onboardingSubjects)
          : null,
      // Navigator (not go_router's context.pop) so the screen also builds
      // without a router, as in the render harness.
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      child: switch (prefs) {
        AsyncData(:final value) => _AcademicForm(prefs: value),
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

enum _Field { school, college, program }

class _AcademicForm extends ConsumerWidget {
  const _AcademicForm({required this.prefs});

  final OnboardingPrefs prefs;

  /// Gap between the fields (Frame 7) and under each label row.
  static const _fieldGap = AppSpacing.md;

  _Field? get _next => prefs.schoolId == null
      ? _Field.school
      : prefs.collegeId == null
      ? _Field.college
      : prefs.programId == null
      ? _Field.program
      : null;

  Color? _accent(_Field field) => _next == field ? AppColors.plume500 : null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final schoolId = prefs.schoolId;
    final collegeId = prefs.collegeId;

    final schools = ref.watch(schoolsProvider).value ?? const [];
    final colleges = schoolId == null
        ? const <College>[]
        : ref.watch(collegesProvider(schoolId)).value ?? const [];
    final programs = collegeId == null
        ? const <Program>[]
        : ref.watch(programsProvider(collegeId)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdown<String>(
          label: 'School',
          placeholder: 'Select School',
          items: [
            for (final school in schools)
              AppDropdownItem(value: school.id, label: school.name),
          ],
          value: schoolId,
          onChanged: schools.isEmpty ? null : controller.selectSchool,
          accentColor: _accent(_Field.school),
          confirmSelection: true,
        ),
        const SizedBox(height: _fieldGap),
        AppDropdown<String>(
          label: 'College',
          placeholder: 'Select College',
          items: [
            for (final college in colleges)
              AppDropdownItem(value: college.id, label: college.name),
          ],
          value: collegeId,
          onChanged: colleges.isEmpty ? null : controller.selectCollege,
          accentColor: _accent(_Field.college),
          confirmSelection: true,
        ),
        const SizedBox(height: _fieldGap),
        AppDropdown<String>(
          label: 'Program',
          placeholder: 'Select Program',
          items: [
            for (final program in programs)
              AppDropdownItem(value: program.id, label: program.name),
          ],
          value: prefs.programId,
          onChanged: programs.isEmpty ? null : controller.selectProgram,
          accentColor: _accent(_Field.program),
          confirmSelection: true,
        ),
        const SizedBox(height: _fieldGap),
        Text(
          'Year level',
          style: AppTypography.b4.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final level in YearLevel.values)
              AppChip.choice(
                label: level.label,
                selected: prefs.yearLevel == level,
                onSelected: (_) => controller.selectYearLevel(level),
                style: AppChipStyle.neutral,
              ),
          ],
        ),
      ],
    );
  }
}
