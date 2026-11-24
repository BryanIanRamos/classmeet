/// Search filter chips (12).
enum SearchCategory {
  all('All'),
  classes('Classes'),
  materials('Materials'),
  people('People');

  const SearchCategory(this.label);

  final String label;
}

/// A class or material hit in search (12). People use `PersonSummary`.
final class SearchResult {
  const SearchResult({
    required this.id,
    required this.category,
    required this.title,
    this.subtitle = '',
  });

  final String id;
  final SearchCategory category;
  final String title;

  /// "Prof. Rhea Santos" or "Created by Ara Matias".
  final String subtitle;

  SearchResult copyWith({
    String? id,
    SearchCategory? category,
    String? title,
    String? subtitle,
  }) {
    return SearchResult(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
