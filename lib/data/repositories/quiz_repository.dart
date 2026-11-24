import '../models/quiz.dart';

/// The user's quizzes (122 "My quizzes", 123) and their questions (124).
abstract interface class QuizRepository {
  Future<List<Quiz>> fetchQuizzes();

  Future<Quiz> fetchQuiz(String quizId);

  Future<List<Question>> fetchQuestions(String quizId);

  /// The quiz the Play hub banner offers to continue (122), if any.
  Future<Quiz?> fetchContinueQuiz();
}
