import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/place.dart';

class SearchState {
  final bool isLoading;
  final String? error;
  final List<Place> results;
  final List<String> recentSearches;
  final List<String> activeFilters;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.results = const [],
    this.recentSearches = const [],
    this.activeFilters = const [],
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    List<Place>? results,
    List<String>? recentSearches,
    List<String>? activeFilters,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(results: []);
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Implémenter la recherche
    state = state.copyWith(isLoading: false, results: []);
  }

  void clearSearch() {
    state = state.copyWith(results: []);
  }

  void clearFilters() {
    state = state.copyWith(activeFilters: []);
  }

  void applyFilters() {
    // TODO: Appliquer les filtres
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  void removeRecentSearch(String search) {
    final newSearches = List<String>.from(state.recentSearches)..remove(search);
    state = state.copyWith(recentSearches: newSearches);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier();
});
