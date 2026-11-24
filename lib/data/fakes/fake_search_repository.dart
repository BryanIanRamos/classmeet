import '../models/profile.dart';
import '../models/search_result.dart';
import '../repositories/search_repository.dart';
import 'fake_config.dart';
import 'samples/search_samples.dart';

/// In-memory [SearchRepository]. [search] keeps the samples whose text
/// contains the query (case-insensitive); an empty query keeps everything.
class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository(this._config, {DateTime Function()? clock})
    : _recent = _config.isEmpty ? [] : List.of(sampleRecentSearches);

  final FakeConfig _config;
  List<String> _recent;

  @override
  Future<List<String>> fetchRecentSearches() =>
      _config.answerList('fetchRecentSearches', () => List.of(_recent));

  @override
  Future<void> clearRecentSearches() =>
      _config.answer('clearRecentSearches', () => _recent = []);

  @override
  Future<SearchResults> search(
    String query, {
    SearchCategory category = SearchCategory.all,
  }) => _config.answer('search', () {
    final needle = query.trim().toLowerCase();
    bool matches(Iterable<String?> texts) =>
        needle.isEmpty ||
        texts.any((t) => t != null && t.toLowerCase().contains(needle));
    bool wants(SearchCategory c) =>
        category == SearchCategory.all || category == c;

    return SearchResults(
      classes: wants(SearchCategory.classes)
          ? [
              for (final r in sampleClassResults)
                if (matches([r.title, r.subtitle])) r,
            ]
          : const [],
      materials: wants(SearchCategory.materials)
          ? [
              for (final r in sampleMaterialResults)
                if (matches([r.title, r.subtitle])) r,
            ]
          : const [],
      people: wants(SearchCategory.people)
          ? <PersonSummary>[
              for (final p in samplePeopleResults)
                if (matches([p.name, p.programLabel, p.schoolName])) p,
            ]
          : const [],
    );
  }, empty: () => const SearchResults());
}
