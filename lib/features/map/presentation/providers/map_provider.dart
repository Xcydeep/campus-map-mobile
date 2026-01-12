import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/coordinate.dart';
import '../../domain/entities/map_route.dart';

class MapState {
  final bool isOnline;
  final List<Place> searchResults;
  final bool isLoading;
  final List<String> activeLayers;
  final List<Place> places;
  final double zoomLevel;
  final Coordinate? centerPosition;
  final MapRoute? currentRoute;
  final List<Building> buildings;

  MapState({
    this.isOnline = true,
    this.searchResults = const <Place>[],
    this.isLoading = false,
    this.activeLayers = const <String>['poi'],
    this.places = const <Place>[],
    this.zoomLevel = 15.0,
    this.centerPosition,
    this.currentRoute,
    this.buildings = const <Building>[],
  });

  MapState copyWith({
    bool? isOnline,
    List<Place>? searchResults,
    bool? isLoading,
    List<String>? activeLayers,
    List<Place>? places,
    double? zoomLevel,
    Coordinate? centerPosition,
    MapRoute? currentRoute,
    List<Building>? buildings,
  }) {
    return MapState(
      isOnline: isOnline ?? this.isOnline,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      activeLayers: activeLayers ?? this.activeLayers,
      places: places ?? this.places,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      centerPosition: centerPosition ?? this.centerPosition,
      currentRoute: currentRoute ?? this.currentRoute,
      buildings: buildings ?? this.buildings,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  void getCurrentLocation() {
    // Récupère la localisation de l'utilisateur
    state = state.copyWith(isLoading: true);
  }

  void centerOnUserLocation() {
    // Centre la carte sur la position de l'utilisateur
    if (state.centerPosition != null) {
      state = state.copyWith(
        centerPosition: state.centerPosition,
        zoomLevel: 16.0,
      );
    }
  }

  void handleSharedLocation(String token) {
    // Gère un lien partagé avec une position
    print('Token partagé reçu: $token');
  }

  void toggleLayer(String layer, bool value) {
    // Active/désactive une couche (POI, Bâtiments, etc.)
    List<String> newLayers = List.from(state.activeLayers);
    if (value) {
      if (!newLayers.contains(layer)) {
        newLayers.add(layer);
      }
    } else {
      newLayers.remove(layer);
    }
    state = state.copyWith(activeLayers: newLayers);
  }

  void selectPlace(Place place) {
    // Sélectionne un lieu sur la carte
    state = state.copyWith(
      centerPosition: Coordinate(
        latitude: place.latitude,
        longitude: place.longitude,
      ),
      zoomLevel: 17.0,
    );
  }

  void onMapTapped(dynamic point) {
    // Gère les clics sur la carte
    print('Carte cliquée à: $point');
  }

  void updateMapPosition(double lat, double lon, double zoom) {
    // Met à jour la position et le zoom de la carte
    state = state.copyWith(
      centerPosition: Coordinate(latitude: lat, longitude: lon),
      zoomLevel: zoom,
    );
  }

  void setPlaces(List<Place> places) {
    // Définit la liste des lieux à afficher
    state = state.copyWith(places: places, isLoading: false);
  }

  void setOnlineStatus(bool isOnline) {
    // Définit l'état de la connexion
    state = state.copyWith(isOnline: isOnline);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
