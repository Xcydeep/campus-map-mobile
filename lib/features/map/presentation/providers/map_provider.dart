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

  void getCurrentLocation() {}
  void centerOnUserLocation() {}
  void handleSharedLocation(String token) {}
  void toggleLayer(String layer, bool value) {}
  void selectPlace(Place place) {}
  void onMapTapped(dynamic point) {}
  void updateMapPosition(double lat, double lon, double zoom) {}
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
