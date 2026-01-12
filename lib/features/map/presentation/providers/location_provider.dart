import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);
}

class LocationState {
  final Location? currentLocation;
  final bool isLoading;
  final String? error;

  LocationState({this.currentLocation, this.isLoading = false, this.error});

  LocationState copyWith({
    Location? currentLocation,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Vérifier les permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Les services de localisation sont désactivés',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Permission de localisation refusée',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Permission de localisation refusée définitivement',
        );
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        currentLocation: Location(position.latitude, position.longitude),
        isLoading: false,
        error: null,
      );

      print('✅ Position obtenue: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Erreur lors de la récupération de la position: $e');
      state = state.copyWith(isLoading: false, error: 'Erreur: $e');
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);
