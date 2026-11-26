import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/quest.dart';
import '../../../data/models/quiz.dart';
import '../../../data/providers.dart';
import 'home_providers.dart';

/// How a finished daily quiz ended: what the result sheet reports (15).
final class DailyQuizResult {
  const DailyQuizResult({
    required this.correct,
    required this.total,
    required this.talonsEarned,
  });

  /// Questions answered right.
  final int correct;
  final int total;

  /// Talons this run added to the wallet. 0 when today's reward was already
  /// taken: the talons are for finishing the quiz once a day, not for the
  /// score.
  final int talonsEarned;

  bool get earnedTalons => talonsEarned > 0;
}

/// Where the quiz stands: the questions, the one shown, the picked option,
/// whether it was checked, how many were right and, once the quiz is over,
/// its [result].
final class DailyQuizState {
  const DailyQuizState({
    required this.questions,
    this.index = 0,
    this.selected,
    this.checked = false,
    this.correctCount = 0,
    this.finishing = false,
    this.finishFailed = false,
    this.result,
  });

  final List<Question> questions;

  /// Zero-based position in [questions].
  final int index;

  /// The option picked for this question, or null.
  final int? selected;

  /// The pick was checked: the options are locked and show the answer.
  final bool checked;
  final int correctCount;

  /// The last question was checked and the quiz is being recorded.
  final bool finishing;

  /// Recording the quiz failed; the finish button tries again.
  final bool finishFailed;
  final DailyQuizResult? result;

  /// False when there is no quiz today (an empty list).
  bool get hasQuestions => questions.isNotEmpty;

  /// The question shown. Only valid when [hasQuestions].
  Question get question => questions[index];

  /// "Question 2 of 5" counts from 1.
  int get number => index + 1;

  bool get isLast => index >= questions.length - 1;

  /// The picked option is the right one. Only meaningful once [checked].
  bool get isCorrect => selected == question.correctIndex;

  bool get canSelect => hasQuestions && !checked && result == null;
  bool get canCheck => canSelect && selected != null;
  bool get canAdvance => hasQuestions && checked && !isLast;
  bool get canFinish =>
      hasQuestions && checked && isLast && !finishing && result == null;

  /// The same quiz with the given fields replaced. It cannot clear
  /// [selected]; [advance] does that.
  DailyQuizState copyWith({
    int? selected,
    bool? checked,
    int? correctCount,
    bool? finishing,
    bool? finishFailed,
    DailyQuizResult? result,
  }) {
    return DailyQuizState(
      questions: questions,
      index: index,
      selected: selected ?? this.selected,
      checked: checked ?? this.checked,
      correctCount: correctCount ?? this.correctCount,
      finishing: finishing ?? this.finishing,
      finishFailed: finishFailed ?? this.finishFailed,
      result: result ?? this.result,
    );
  }

  /// The next question, with nothing picked.
  DailyQuizState advance() => DailyQuizState(
    questions: questions,
    index: index + 1,
    correctCount: correctCount,
  );
}

/// Drives the Daily General Knowledge Quiz (15): pick an option, check it,
/// go to the next question, and after the last one record the quiz.
///
/// Recording is the talon quest of the day (14): [finish] marks the quiz done
/// and, when that earned today's reward, claims the quest and adds the talons
/// to the wallet. The talons are for finishing, not for the score. The fakes
/// keep the quest and the wallet apart, so claiming and earning are two
/// calls; a backend would do both at once.
///
/// The provider is auto-disposed with the screen, so leaving starts the quiz
/// over. Late answers are dropped after the provider is gone (`ref.mounted`),
/// except for [finish]: it keeps the provider alive until every step has
/// run, so leaving at the wrong moment cannot claim the quest without paying
/// the talons.
class DailyQuizController extends AsyncNotifier<DailyQuizState> {
  /// Talons of a quest that was claimed but not yet added to the wallet,
  /// because adding them failed. The next [finish] pays them instead of
  /// asking the repository again, where the quest now reads as claimed and
  /// would pay nothing. It lives as long as the provider, so a student who
  /// leaves after the failure is not paid; the fakes cannot fail this way
  /// and a backend would pay on claim.
  int? _unpaid;

  @override
  Future<DailyQuizState> build() async {
    final questions = await ref.watch(questRepositoryProvider).fetchDailyQuiz();
    return DailyQuizState(questions: questions);
  }

  /// Picks [option] for the current question; ignored once it is checked.
  void select(int option) {
    final quiz = state.value;
    if (quiz == null || !quiz.canSelect) return;
    if (option < 0 || option >= quiz.question.options.length) return;
    state = AsyncData(quiz.copyWith(selected: option));
  }

  /// Checks the pick: the options lock and the answer shows. Needs a pick.
  void check() {
    final quiz = state.value;
    if (quiz == null || !quiz.canCheck) return;
    state = AsyncData(
      quiz.copyWith(
        checked: true,
        correctCount: quiz.correctCount + (quiz.isCorrect ? 1 : 0),
      ),
    );
  }

  /// Moves on to the next question. Needs a checked answer and a next one.
  void next() {
    final quiz = state.value;
    if (quiz == null || !quiz.canAdvance) return;
    state = AsyncData(quiz.advance());
  }

  /// Records the finished quiz and returns its result, or null when there is
  /// nothing to finish yet, a finish is already running, or recording failed
  /// (then [DailyQuizState.finishFailed] is set and a new call tries again).
  Future<DailyQuizResult?> finish() async {
    final current = state.value;
    if (current == null || !current.canFinish) return null;

    final keepAlive = ref.keepAlive();
    final working = current.copyWith(finishing: true, finishFailed: false);
    state = AsyncData(working);
    try {
      final quests = ref.read(questRepositoryProvider);
      final wallet = ref.read(walletRepositoryProvider);

      if (_unpaid == null) {
        final quest = await quests.finishDailyQuiz();
        if (!ref.mounted) return null;
        // Completed and not yet claimed: today's reward is due. A quest that
        // was already claimed comes back as such, and pays nothing twice.
        if (quest.status == QuestStatus.completed) {
          await quests.claimQuest(quest.id);
          if (!ref.mounted) return null;
          _unpaid = quest.rewardTalons;
        }
      }

      var earned = 0;
      final unpaid = _unpaid;
      if (unpaid != null) {
        await wallet.earn(talons: unpaid);
        if (!ref.mounted) return null;
        _unpaid = null;
        earned = unpaid;
        ref
          ..invalidate(questsProvider)
          ..invalidate(walletProvider);
      }

      final result = DailyQuizResult(
        correct: working.correctCount,
        total: working.questions.length,
        talonsEarned: earned,
      );
      state = AsyncData(working.copyWith(finishing: false, result: result));
      return result;
    } on Object {
      if (ref.mounted) {
        state = AsyncData(
          working.copyWith(finishing: false, finishFailed: true),
        );
      }
      return null;
    } finally {
      keepAlive.close();
    }
  }
}

final dailyQuizControllerProvider =
    AsyncNotifierProvider.autoDispose<DailyQuizController, DailyQuizState>(
      DailyQuizController.new,
    );
