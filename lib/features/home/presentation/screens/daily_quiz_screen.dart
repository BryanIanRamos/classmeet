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
import '../../application/daily_quiz_controller.dart';
import '../../application/home_providers.dart';
import '../widgets/daily_quiz_footer.dart';
import '../widgets/daily_quiz_question_view.dart';
import '../widgets/daily_quiz_result_sheet.dart';
import '../widgets/daily_quiz_reward_row.dart';

/// Daily General Knowledge Quiz (frame 15): five questions, one at a time.
///
/// A back bar, the reward strip ("Resets at midnight", "+5 talons", from the
/// daily quest; hidden while the quests are unavailable) and, on the doodle
/// background, the question with its options, scrolling, over a pinned
/// button. Pick an option, "Check answer" (disabled until one is picked)
/// locks the options and shows the answer with its explanation, then "Next
/// question" (INC-4), or "Finish quiz" on the last one. Only the question
/// state is designed (15); the rest, including the result sheet, is
/// provisional.
///
/// Finishing records the quiz: the first time today it earns the quest's
/// talons, and the result sheet says so; later it says they were already
/// earned. The talons are for finishing, not for the score. "Done"
/// leaves the quiz. Back mid-quiz just leaves it, and the progress with it.
///
/// Loading shows a loader; a failed load an [ErrorState] whose retry loads
/// the quiz again; an empty quiz an [EmptyState] (provisional copy, GAP-21).
class DailyQuizScreen extends ConsumerStatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  ConsumerState<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends ConsumerState<DailyQuizScreen> {
  /// How long the page takes to scroll the answer's feedback into view.
  static const _revealDuration = Duration(milliseconds: 250);

  final _feedbackKey = GlobalKey();

  /// After checking, scrolls the feedback card into view if it sits below the
  /// fold (long questions, small screens). Nothing moves when it is visible.
  void _revealFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _feedbackKey.currentContext;
      if (!mounted || target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: _revealDuration,
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  /// Records the quiz, then shows the result and leaves. Nothing happens when
  /// the screen is gone by the time the answer arrives (the controller still
  /// finishes its work).
  Future<void> _finish() async {
    final controller = ref.read(dailyQuizControllerProvider.notifier);
    final result = await controller.finish();
    if (result == null || !mounted) return;
    await showDailyQuizResultSheet(context, result);
    if (!mounted) return;
    await Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(dailyQuizControllerProvider);
    final quests = ref.watch(questsProvider).value ?? const <Quest>[];
    final daily = quests.where((q) => q.kind == QuestKind.daily).firstOrNull;

    // Scroll the feedback into view the moment an answer is checked.
    ref.listen(
      dailyQuizControllerProvider.select((s) => s.value?.checked ?? false),
      (previous, checked) {
        if (checked && previous != true) _revealFeedback();
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
                  title: 'Daily General Knowledge Quiz',
                  onBack: () => Navigator.maybePop(context),
                ),
                if (daily != null)
                  DailyQuizRewardRow(
                    rewardTalons: daily.rewardTalons,
                    resets: daily.resetsAt != null,
                  ),
              ],
            ),
          ),
          Expanded(child: ScreenBackground(child: _body(quiz))),
        ],
      ),
    );
  }

  Widget _body(AsyncValue<DailyQuizState> quiz) {
    if (quiz.hasError && !quiz.isLoading) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ErrorState(
            onRetry: () => ref.invalidate(dailyQuizControllerProvider),
          ),
        ),
      );
    }
    if (!quiz.hasValue || quiz.isLoading) {
      return const Center(child: AppLoader());
    }
    final state = quiz.requireValue;
    if (!state.hasQuestions) {
      return const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: EmptyState(
            title: 'No quiz today',
            message: 'Check back tomorrow for a new set of questions.',
          ),
        ),
      );
    }
    return _QuizBody(
      state: state,
      feedbackKey: _feedbackKey,
      onFinish: _finish,
    );
  }
}

/// The question over its pinned button.
class _QuizBody extends ConsumerWidget {
  const _QuizBody({
    required this.state,
    required this.feedbackKey,
    required this.onFinish,
  });

  final DailyQuizState state;
  final Key feedbackKey;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dailyQuizControllerProvider.notifier);

    final String label;
    final VoidCallback? onPressed;
    if (!state.checked) {
      label = 'Check answer';
      onPressed = state.canCheck ? controller.check : null;
    } else if (state.isLast) {
      label = 'Finish quiz';
      onPressed = state.canFinish ? onFinish : null;
    } else {
      label = 'Next question';
      onPressed = controller.next;
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            // A new scroll view per question starts it at the top.
            key: ValueKey(state.index),
            // The page's 12, and the design's 24 spacer before the button.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xl,
            ),
            child: DailyQuizQuestionView(
              question: state.question,
              number: state.number,
              total: state.questions.length,
              selected: state.selected,
              checked: state.checked,
              onSelect: controller.select,
              feedbackKey: feedbackKey,
            ),
          ),
        ),
        DailyQuizFooter(
          label: label,
          onPressed: onPressed,
          failed: state.finishFailed,
        ),
      ],
    );
  }
}
