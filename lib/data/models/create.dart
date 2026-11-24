/// A tool in the Create sheet and screen (119, 121). Only quizzes is designed.
enum CreateTool {
  quizzes('Quizzes', 'Test your knowledge as you go', 2, true),
  flashcards('Flashcards', 'Review key terms and concepts', 1, false),
  visualSummaries(
    'Visual summaries',
    'Learn with diagrams and mind maps',
    1,
    false,
  ),
  stepByStep(
    'Step-by-step explanations',
    'Break down difficult topics',
    1,
    false,
  ),
  readingSummaries(
    'Reading summaries',
    'Review the key points quickly',
    null,
    false,
  ),
  manualQuiz('Manual quiz', "Create and test what you've learned", null, false);

  const CreateTool(this.label, this.caption, this.talonCost, this.isDesigned);
  final String label;
  final String caption;

  /// Talon cost; null means free.
  final int? talonCost;
  final bool isDesigned;
}

/// Quiz difficulty (115).
enum Difficulty {
  easy('Easy'),
  mixed('Mixed'),
  hard('Hard');

  const Difficulty(this.label);
  final String label;
}

/// Question type (115, 123).
enum QuestionType {
  multipleChoice('Multiple choice'),
  trueOrFalse('True or false'),
  fillInTheBlanks('Fill-in-the-Blanks'),
  identification('Identification');

  const QuestionType(this.label);
  final String label;
}

/// An unfinished item under "Continue creating" (121).
final class Draft {
  const Draft({
    required this.id,
    required this.title,
    required this.tool,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final CreateTool tool;
  final DateTime updatedAt;

  Draft copyWith({
    String? id,
    String? title,
    CreateTool? tool,
    DateTime? updatedAt,
  }) => Draft(
    id: id ?? this.id,
    title: title ?? this.title,
    tool: tool ?? this.tool,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// The quiz creation form across the three steps (114, 115, 116).
final class QuizSetup {
  const QuizSetup({
    this.sourceMaterialId,
    this.title = '',
    this.questionCount = 10,
    this.difficulty = Difficulty.mixed,
    this.questionTypes = const {
      QuestionType.multipleChoice,
      QuestionType.fillInTheBlanks,
    },
    this.showExplanations = true,
    this.shuffle = true,
  });

  /// Choices offered for the number of questions.
  static const questionCountChoices = [5, 10, 15, 20];

  final String? sourceMaterialId;
  final String title;
  final int questionCount;
  final Difficulty difficulty;
  final Set<QuestionType> questionTypes;
  final bool showExplanations;
  final bool shuffle;

  QuizSetup copyWith({
    String? sourceMaterialId,
    String? title,
    int? questionCount,
    Difficulty? difficulty,
    Set<QuestionType>? questionTypes,
    bool? showExplanations,
    bool? shuffle,
  }) => QuizSetup(
    sourceMaterialId: sourceMaterialId ?? this.sourceMaterialId,
    title: title ?? this.title,
    questionCount: questionCount ?? this.questionCount,
    difficulty: difficulty ?? this.difficulty,
    questionTypes: questionTypes ?? this.questionTypes,
    showExplanations: showExplanations ?? this.showExplanations,
    shuffle: shuffle ?? this.shuffle,
  );
}

/// Stage of the generating screen (117).
enum GenerationStage {
  reading('Reading your material', 'Reviewing your material'),
  creating('Creating questions', 'Building a balanced practice quiz'),
  checking('Checking answers', 'Preparing answers and explanations'),
  saving('Saving your quiz', 'Adding it to your study materials'),
  done('Done', ''),
  failed('Failed', '');

  const GenerationStage(this.title, this.caption);
  final String title;

  /// Step caption. The design's reading caption is "Reviewing" plus the material title,
  /// so the UI should substitute the title for [reading].
  final String caption;
}

/// A quiz generation in progress (117).
final class GenerationJob {
  const GenerationJob({
    required this.id,
    this.setup,
    this.quizId,
    this.stage = GenerationStage.reading,
    this.done = 0,
    this.total = 0,
  });

  final String id;
  final QuizSetup? setup;
  final String? quizId;
  final GenerationStage stage;
  final int done;
  final int total;

  /// Progress, 0..1 (0 when total is 0).
  double get fraction => total <= 0 ? 0 : (done / total).clamp(0.0, 1.0);

  GenerationJob copyWith({
    String? id,
    QuizSetup? setup,
    String? quizId,
    GenerationStage? stage,
    int? done,
    int? total,
  }) => GenerationJob(
    id: id ?? this.id,
    setup: setup ?? this.setup,
    quizId: quizId ?? this.quizId,
    stage: stage ?? this.stage,
    done: done ?? this.done,
    total: total ?? this.total,
  );
}
