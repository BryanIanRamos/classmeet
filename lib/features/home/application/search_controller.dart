import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/search_result.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/search_repository.dart';

/// The query, the chosen category chip and the answer for it (12).
final class SearchState {
  const SearchState({
    this.query = '',
    this.category = SearchCategory.all,
    this.results = const AsyncData(SearchResults()),
    this.loading = false,
  });

  final String query;
  final SearchCategory category;

  /// Answer for [query] and [category]; empty while the query is blank.
  final AsyncValue<SearchResults> results;

  /// A search is running; [results] still holds the previous answer.
  final bool loading;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchCategory? category,
    AsyncValue<SearchResults>? results,
    bool? loading,
  }) {
    return SearchState(
      query: query ?? this.query,
      category: category ?? this.category,
      results: results ?? this.results,
      loading: loading ?? this.loading,
    );
  }
}

/// Drives the Search screen: typing is debounced by [debounce], recent
/// searches and chips search right away. Late answers of an older query are
/// dropped, and so is any answer that arrives after the screen closed (the
/// provider is auto-disposed).
class HomeSearchController extends Notifier<SearchState> {
  /// Pause after the last key before the search runs.
  static const debounce = Duration(milliseconds: 300);

  Timer? _timer;
  int _generation = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SearchState();
  }

  /// Typing: updates the query now and searches after [debounce]. Pass
  /// [immediate] to search at once (recent searches, a preset query).
  void setQuery(String query, {bool immediate = false}) {
    _timer?.cancel();
    state = state.copyWith(query: query);
    if (!state.hasQuery) {
      _generation++;
      state = state.copyWith(
        results: const AsyncData(SearchResults()),
        loading: false,
      );
      return;
    }
    state = state.copyWith(loading: true);
    if (immediate) {
      unawaited(_run());
    } else {
      _timer = Timer(debounce, () => unawaited(_run()));
    }
  }

  void selectCategory(SearchCategory category) {
    if (category == state.category) return;
    _timer?.cancel();
    state = state.copyWith(category: category);
    if (state.hasQuery) {
      state = state.copyWith(loading: true);
      unawaited(_run());
    }
  }

  /// Searches again, e.g. after an error.
  void retry() {
    if (!state.hasQuery) return;
    _timer?.cancel();
    state = state.copyWith(loading: true);
    unawaited(_run());
  }

  Future<void> _run() async {
    final generation = ++_generation;
    final query = state.query;
    final category = state.category;
    final result = await AsyncValue.guard(
      () => ref
          .read(searchRepositoryProvider)
          .search(query.trim(), category: category),
    );
    if (!ref.mounted || generation != _generation) return;
    state = state.copyWith(results: result, loading: false);
  }
}

final homeSearchControllerProvider =
    NotifierProvider.autoDispose<HomeSearchController, SearchState>(
      HomeSearchController.new,
    );

/// Recent searches (12). Failures read as "no recents".
class RecentSearches extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    try {
      return await ref.read(searchRepositoryProvider).fetchRecentSearches();
    } on Object {
      return const [];
    }
  }

  /// "Clear all".
  Future<void> clear() async {
    await ref.read(searchRepositoryProvider).clearRecentSearches();
    if (!ref.mounted) return;
    state = const AsyncData([]);
  }
}

final recentSearchesProvider =
    AsyncNotifierProvider.autoDispose<RecentSearches, List<String>>(
      RecentSearches.new,
    );
