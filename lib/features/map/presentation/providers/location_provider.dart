import 'package:flutter_riverpod/legacy.dart';

class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);
}

class LocationState {
  final Location? currentLocation;

  LocationState({this.currentLocation});

  LocationState copyWith({Location? currentLocation}) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  void getCurrentLocation() {}
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);
