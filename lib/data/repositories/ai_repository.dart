import '../models/reader.dart';

/// AI help on selected text (87 toolbar, 91 sheet). The fake returns canned
/// answers and spends talons through the wallet; the real one calls the
/// server-side proxy, never the model API directly (D-13).
abstract interface class AiRepository {
  /// Explains [text] from [materialId] for [action] in [language]. Spends
  /// the answer's talon cost; throws a `RepositoryException` when the
  /// balance is too low.
  Future<Explanation> explain({
    required String materialId,
    required String text,
    ExplainAction action = ExplainAction.explain,
    ExplainLanguage language = ExplainLanguage.english,
  });
}
