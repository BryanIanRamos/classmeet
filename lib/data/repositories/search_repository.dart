import '../models/profile.dart';
import '../models/search_result.dart';

/// Search over classes, materials and people (12).
abstract interface class SearchRepository {
  Future<List<String>> fetchRecentSearches();

  Future<void> clearRecentSearches();

  Future<SearchResults> search(
    String query, {
    SearchCategory category = SearchCategory.all,
  });
}

/// One search answer, grouped like screen 12.
final class SearchResults {
  const SearchResults({
    this.classes = const [],
    this.materials = const [],
    this.people = const [],
  });

  final List<SearchResult> classes;
  final List<SearchResult> materials;
  final List<PersonSummary> people;

  bool get isEmpty => classes.isEmpty && materials.isEmpty && people.isEmpty;
}
