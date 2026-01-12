import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/place.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'api_providers.dart';

class SearchState {
  final bool isLoading;
  final String? error;
  final List<Place> results;
  final List<String> recentSearches;
  final List<String> activeFilters;
  final String query;

  const SearchState({
    this.isLoading = false,
    this.error,
    this.results = const [],
    this.recentSearches = const [],
    this.activeFilters = const [],
    this.query = '',
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    List<Place>? results,
    List<String>? recentSearches,
    List<String>? activeFilters,
    String? query,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      activeFilters: activeFilters ?? this.activeFilters,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final List<Place> _allPlaces;

  SearchNotifier(this._allPlaces) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(results: [], query: '');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      List<Place> results = [];

      // 1. Rechercher dans les places existantes
      final placesResults = _allPlaces.where((place) {
        final queryLower = query.toLowerCase();
        return place.name.toLowerCase().contains(queryLower) ||
            (place.description?.toLowerCase().contains(queryLower) ?? false) ||
            (place.address?.toLowerCase().contains(queryLower) ?? false) ||
            (place.category.toLowerCase().contains(queryLower));
      }).toList();

      results.addAll(placesResults);

      // 2. Si pas de résultats, essayer la géocodage (recherche d'adresses)
      if (results.isEmpty) {
        try {
          List<geocoding.Location> locations = await geocoding.locationFromAddress(query);
          if (locations.isNotEmpty) {
            // Créer des places temporaires pour les résultats de géocodage
            for (var location in locations) {
              // Récupérer l'adresse complète
              List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
                location.latitude,
                location.longitude,
              );

              if (placemarks.isNotEmpty) {
                final placemark = placemarks.first;
                final address = [
                  placemark.street,
                  placemark.locality,
                  placemark.administrativeArea,
                  placemark.country,
                ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

                results.add(Place(
                  id: 'geocoding_${location.latitude}_${location.longitude}',
                  name: address.isNotEmpty ? address : query,
                  category: 'adresse',
                  latitude: location.latitude,
                  longitude: location.longitude,
                  description: 'Résultat de recherche',
                  address: address,
                ));
              }
            }
          }
        } catch (e) {
          print('Erreur géocodage: $e');
          // Continuer même si la géocodage échoue
        }
      }

      state = state.copyWith(
        isLoading: false,
        results: results,
        error: results.isEmpty ? 'Aucun résultat trouvé' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la recherche: $e',
        results: [],
      );
    }
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
  // Récupérer les places depuis le provider
  final placesAsync = ref.watch(poisProvider);
  final places = placesAsync.value ?? [];
  return SearchNotifier(places);
});
