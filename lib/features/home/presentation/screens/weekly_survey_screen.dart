import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../../../data/models/quest.dart';
import '../../application/home_providers.dart';
import '../../application/weekly_survey_controller.dart';
import '../home_format.dart';
import '../widgets/survey_footer.dart';
import '../widgets/survey_info_card.dart';
import '../widgets/survey_intro.dart';
import '../widgets/survey_question_block.dart';
import '../widgets/survey_result_sheet.dart';
import '../widgets/survey_reward_row.dart';

/// Weekly Survey (frame 16): three short questions, each skippable.
///
/// A back bar, the reward strip ("Available until Sunday", "+5 talons", from
/// the survey quest; hidden while the quests are unavailable) and, on the
/// doodle background, the whole survey scrolling: the heading, the questions
/// (chips for the first, radio cards for the others, as the survey says), the
/// "Your feedback matters" card, the submit button and "Skip survey".
///
/// Pick at most one option per question; tapping the picked one again keeps
/// it. Every question can be skipped, so Submit is enabled with nothing picked
/// and sends whatever is. The first submit of the week earns the quest's
/// talons and the result sheet says so; after that it says they were already
/// earned. The result sheet is provisional (the design has none). "Done"
/// leaves the survey. "Skip survey" and Back leave it without sending.
///
/// A failed submit shows a notice above the button, which stays usable to try
/// again. Loading shows a loader; a failed load an [ErrorState] whose retry
/// loads the survey again; a survey without questions an [EmptyState]
/// (provisional copy, GAP-21).
///
/// Sizes: the page is 12 from the sides, each block adds its own 12, so
/// content starts 24 in. The design's selected radio card is 48 tall, 2 less
/// than the others (INC-15); the cards keep 50 so picking does not move the
/// page, and the page runs 2 longer per picked radio card than the frame.
class WeeklySurveyScreen extends ConsumerStatefulWidget {
  const WeeklySurveyScreen({super.key});

  @override
  ConsumerState<WeeklySurveyScreen> createState() => _WeeklySurveyScreenState();
}

class _WeeklySurveyScreenState extends ConsumerState<WeeklySurveyScreen> {
  /// How long the page takes to scroll the failure notice into view.
  static const _revealDuration = Duration(milliseconds: 250);

  final _footerKey = GlobalKey();

  /// After a failed submit, scrolls the notice and the button above the fold
  /// (the notice pushes the button down while the page stays where it is).
  void _revealFooter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _footerKey.currentContext;
      if (!mounted || target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: _revealDuration,
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  /// Sends the survey, then shows the result and leaves. Nothing happens when
  /// the screen is gone by the time the answer arrives (the controller still
  /// finishes its work).
  Future<void> _submit() async {
    final controller = ref.read(weeklySurveyControllerProvider.notifier);
    final result = await controller.submit();
    if (result == null || !mounted) return;
    await showSurveyResultSheet(context, result);
    if (!mounted) return;
    await Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final survey = ref.watch(weeklySurveyControllerProvider);
    final quests = ref.watch(questsProvider).value ?? const <Quest>[];
    final quest = quests.where((q) => q.kind == QuestKind.survey).firstOrNull;
    final until = quest?.availableUntil;

    // Show the notice and the button again the moment a submit fails.
    ref.listen(
      weeklySurveyControllerProvider.select(
        (s) => s.value?.submitFailed ?? false,
      ),
      (previous, failed) {
        if (failed && previous != true) _revealFooter();
      },
    );

    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppNavbarTop(
                  title: 'Weekly Survey',
                  onBack: () => Navigator.maybePop(context),
                ),
                if (quest != null)
                  SurveyRewardRow(
                    rewardTalons: quest.rewardTalons,
                    availability: until == null
                        ? null
                        : availableUntilLabel(until),
                  ),
              ],
            ),
          ),
          Expanded(child: ScreenBackground(child: _body(survey, quest))),
        ],
      ),
    );
  }

  Widget _body(AsyncValue<WeeklySurveyState> survey, Quest? quest) {
    if (survey.hasError && !survey.isLoading) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ErrorState(
            onRetry: () => ref.invalidate(weeklySurveyControllerProvider),
          ),
        ),
      );
    }
    if (!survey.hasValue || survey.isLoading) {
      return const Center(child: AppLoader());
    }
    final state = survey.requireValue;
    if (!state.hasQuestions) {
      return const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: EmptyState(
            title: 'No survey this week',
            message: 'Check back on Monday for a new one.',
          ),
        ),
      );
    }
    final controller = ref.read(weeklySurveyControllerProvider.notifier);
    return _SurveyBody(
      state: state,
      // The quest's reward when it is known, else the survey's own.
      rewardTalons: quest?.rewardTalons ?? state.survey.rewardTalons,
      footerKey: _footerKey,
      onSelect: controller.select,
      onSubmit: _submit,
    );
  }
}

/// The scrolling survey: heading, questions, card, button and skip link.
class _SurveyBody extends StatelessWidget {
  const _SurveyBody({
    required this.state,
    required this.rewardTalons,
    required this.footerKey,
    required this.onSelect,
    required this.onSubmit,
  });

  final WeeklySurveyState state;
  final int rewardTalons;
  final Key footerKey;

  /// Called with a question's id and the index of the option picked for it.
  final void Function(String questionId, int option) onSelect;
  final VoidCallback onSubmit;

  /// The page's padding (spec "Frame 6": 12); the design's home-indicator
  /// space is the bottom safe-area inset, under it.
  static const _pagePadding = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final questions = state.survey.questions;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _pagePadding,
        _pagePadding,
        _pagePadding,
        _pagePadding + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurveyIntro(title: state.survey.title),
          for (var i = 0; i < questions.length; i++)
            SurveyQuestionBlock(
              number: i + 1,
              question: questions[i],
              selected: state.answers[questions[i].id],
              onSelect: (option) => onSelect(questions[i].id, option),
              divider: i < questions.length - 1,
            ),
          // Spec "Frame 1196": padding 16 around the card.
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SurveyInfoCard(),
          ),
          SurveyFooter(
            key: footerKey,
            rewardTalons: rewardTalons,
            onSubmit: state.isOpen ? onSubmit : null,
            onSkip: () => Navigator.maybePop(context),
            failed: state.submitFailed,
          ),
        ],
      ),
    );
  }
}
