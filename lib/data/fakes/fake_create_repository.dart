import '../models/create.dart';
import '../models/quiz.dart';
import '../repositories/create_repository.dart';
import '../repositories/repository_exception.dart';
import '../repositories/wallet_repository.dart';
import 'fake_config.dart';
import 'fake_quiz_repository.dart';
import 'samples/create_samples.dart';

/// [CreateRepository] with a staged fake generation. The new quiz joins the
/// [FakeQuizRepository] and draws its questions from the Week 1 pool.
class FakeCreateRepository implements CreateRepository {
  FakeCreateRepository(
    this._config, {
    required this._quizzes,
    required this._wallet,
  });

  final FakeConfig _config;
  final FakeQuizRepository _quizzes;
  final WalletRepository _wallet;
  var _nextJob = 1;
  var _nextQuiz = 1;

  @override
  Future<List<Draft>> fetchDrafts() =>
      _config.answerList('fetchDrafts', () => List.of(sampleDrafts));

  /// Progress is reported out of 100: 0, 25, 50, 75 and 100 per cent.
  static const _progressTotal = 100;

  Future<void> _pause() async {
    final delay = _config.latency;
    if (delay != null && delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  @override
  Stream<GenerationJob> generateQuiz(QuizSetup setup) async* {
    if (_config.scenario == FakeScenario.error) {
      await _pause();
      throw const RepositoryException(
        'generateQuiz failed (FAKE_SCENARIO=error)',
      );
    }
    await _pause();
    // Throws (and so ends the stream with an error) when talons run out.
    await _wallet.spendTalons(
      CreateTool.quizzes.talonCost!,
      reason: 'Generate quiz',
    );

    final jobId = 'job-${_nextJob++}';
    GenerationJob job(GenerationStage stage, int step, {String? quizId}) =>
        GenerationJob(
          id: jobId,
          setup: setup,
          quizId: quizId,
          stage: stage,
          done: step * _progressTotal ~/ 4,
          total: _progressTotal,
        );

    yield job(GenerationStage.reading, 0);
    await _pause();
    yield job(GenerationStage.creating, 1);
    await _pause();
    yield job(GenerationStage.checking, 2);
    await _pause();
    yield job(GenerationStage.saving, 3);
    await _pause();

    final quizId = 'generated-${_nextQuiz++}';
    final pool = weekOneQuestionPool;
    final questions = [
      for (var i = 0; i < setup.questionCount; i++)
        pool[i % pool.length].copyWith(id: '$quizId-q${i + 1}'),
    ];
    final title = setup.title.trim();
    _quizzes.addQuiz(
      Quiz(
        id: quizId,
        title: title.isEmpty ? sampleGeneratedTitle : title,
        classCode: sampleGeneratedClassCode,
        questionCount: questions.length,
        difficulty: setup.difficulty,
        types: setup.questionTypes,
        isAiGenerated: true,
      ),
      questions,
    );
    yield job(GenerationStage.done, 4, quizId: quizId);
  }
}
