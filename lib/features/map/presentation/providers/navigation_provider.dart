import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/coordinate.dart';
import '../../domain/entities/map_route.dart';
import '../../domain/entities/place.dart';

class NavigationState {
  final MapRoute? currentRoute;
  final List<Coordinate>? routePolyline;
  final Coordinate? startPoint;
  final Place? destination;
  final String transportMode;
  final bool isCalculating;
  final String? error;

  const NavigationState({
    this.currentRoute,
    this.routePolyline,
    this.startPoint,
    this.destination,
    this.transportMode = 'walking',
    this.isCalculating = false,
    this.error,
  });

  NavigationState copyWith({
    MapRoute? currentRoute,
    List<Coordinate>? routePolyline,
    Coordinate? startPoint,
    Place? destination,
    String? transportMode,
    bool? isCalculating,
    String? error,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      routePolyline: routePolyline ?? this.routePolyline,
      startPoint: startPoint ?? this.startPoint,
      destination: destination ?? this.destination,
      transportMode: transportMode ?? this.transportMode,
      isCalculating: isCalculating ?? this.isCalculating,
      error: error,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void calculateRoute({
    required String destinationId,
    double? startLat,
    double? startLon,
  }) {
    state = state.copyWith(isCalculating: true, error: null);
    // TODO: Implémenter le calcul d'itinéraire
    state = state.copyWith(isCalculating: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
