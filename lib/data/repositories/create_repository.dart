import '../models/create.dart';

/// Creating study tools (119–121) and the quiz wizard's generation (114–118).
abstract interface class CreateRepository {
  /// "Continue creating" drafts (121).
  Future<List<Draft>> fetchDrafts();

  /// Generates a quiz from [setup], emitting each stage (117) until
  /// [GenerationStage.done] (with the new quiz id) or
  /// [GenerationStage.failed]. Spends the tool's talon cost first.
  Stream<GenerationJob> generateQuiz(QuizSetup setup);
}
