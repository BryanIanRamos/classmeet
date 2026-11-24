import 'create.dart';

/// A playable quiz (118, 122, 123).
final class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.classCode,
    required this.questionCount,
    required this.difficulty,
    this.types = const {},
    this.bestPercent,
    this.isAiGenerated = false,
  });

  final String id;
  final String title;

  /// e.g. "ITE13".
  final String classCode;
  final int questionCount;
  final Difficulty difficulty;
  final Set<QuestionType> types;
  final int? bestPercent;
  final bool isAiGenerated;

  Quiz copyWith({
    String? id,
    String? title,
    String? classCode,
    int? questionCount,
    Difficulty? difficulty,
    Set<QuestionType>? types,
    int? bestPercent,
    bool? isAiGenerated,
  }) => Quiz(
    id: id ?? this.id,
    title: title ?? this.title,
    classCode: classCode ?? this.classCode,
    questionCount: questionCount ?? this.questionCount,
    difficulty: difficulty ?? this.difficulty,
    types: types ?? this.types,
    bestPercent: bestPercent ?? this.bestPercent,
    isAiGenerated: isAiGenerated ?? this.isAiGenerated,
  );
}

/// A question (15, 124, 125, 126).
final class Question {
  const Question({
    required this.id,
    required this.prompt,
    this.category,
    this.type = QuestionType.multipleChoice,
    this.options = const [],
    required this.correctIndex,
    this.explanation,
    this.sourceLabel,
  });

  final String id;
  final String prompt;

  /// e.g. "Science & Society" (15).
  final String? category;
  final QuestionType type;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  /// e.g. "Based on your Week 1: Computer Basics Reviewer".
  final String? sourceLabel;

  Question copyWith({
    String? id,
    String? prompt,
    String? category,
    QuestionType? type,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? sourceLabel,
  }) => Question(
    id: id ?? this.id,
    prompt: prompt ?? this.prompt,
    category: category ?? this.category,
    type: type ?? this.type,
    options: options ?? this.options,
    correctIndex: correctIndex ?? this.correctIndex,
    explanation: explanation ?? this.explanation,
    sourceLabel: sourceLabel ?? this.sourceLabel,
  );
}

/// Game mode cards and rows (122, 123). Quiz Battle is not designed (GAP-15).
enum GameMode {
  standard(
    'Standard',
    'Learn at your pace',
    'Practice with explanations after every answer',
    true,
  ),
  streakRun(
    'Streak Run',
    'Keep the combo alive',
    'Earn bonus points for consecutive correct answers',
    true,
  ),
  reviewerQuest(
    'Reviewer Quest',
    'Adventure mode',
    'Clear challenges and reach the chapter boss',
    true,
  ),
  quizBattle(
    'Quiz Battle',
    'Challenge friends',
    'Practice and challenge with friends',
    false,
  );

  const GameMode(this.label, this.caption, this.longCaption, this.isDesigned);
  final String label;

  /// Short caption on the hub card (122).
  final String caption;

  /// Long caption on the setup row (123).
  final String longCaption;
  final bool isDesigned;
}

/// Toggles under "Game settings" (123).
final class GameSettings {
  const GameSettings({
    this.askBeforeReveal = true,
    this.showComments = true,
    this.timed = false,
  });

  final bool askBeforeReveal;
  final bool showComments;
  final bool timed;

  GameSettings copyWith({
    bool? askBeforeReveal,
    bool? showComments,
    bool? timed,
  }) => GameSettings(
    askBeforeReveal: askBeforeReveal ?? this.askBeforeReveal,
    showComments: showComments ?? this.showComments,
    timed: timed ?? this.timed,
  );
}
