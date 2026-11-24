import '../../models/create.dart';
import '../../models/quiz.dart';
import 'quiz_samples.dart';

/// 121 "Continue creating": one draft.
final List<Draft> sampleDrafts = [
  Draft(
    id: 'draft-1',
    title: 'Intro to Computing Quiz',
    tool: CreateTool.manualQuiz,
    updatedAt: DateTime(2026, 11, 22, 18),
  ),
];

/// Title of a generated quiz when the setup has none (115's prefill).
const sampleGeneratedTitle = 'Week 1: Computer Basics Quiz';

/// Class code of generated quizzes.
const sampleGeneratedClassCode = 'ITE13';

/// The "Week 1: Computer Basics" pool a generated quiz draws from.
List<Question> get weekOneQuestionPool =>
    sampleIntroComputingQuestions.take(12).toList();
