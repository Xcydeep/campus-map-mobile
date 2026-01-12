import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/map_provider.dart';
import '../providers/location_provider.dart' as loc;
import '../../domain/entities/place.dart';
import '../../domain/entities/map_route.dart';

/// Widget Google Maps pour remplacer FlutterMap
///
/// Pour utiliser ce widget, remplacez MapWidget par GoogleMapWidget dans map_screen.dart
class GoogleMapWidget extends ConsumerStatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  ConsumerState<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends ConsumerState<GoogleMapWidget> {
  gmaps.GoogleMapController? _mapController;
  Set<gmaps.Marker> _markers = {};
  Set<gmaps.Polyline> _polylines = {};
  List<Place> _lastPlaces = [];
  MapRoute? _lastRoute;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🗺️ Initialisation de Google Maps...');
    // Détecter les erreurs après un délai
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _mapController == null && _errorMessage == null) {
        print('⚠️ Google Maps ne s\'est pas initialisé après 3 secondes');
        setState(() {
          _errorMessage =
              'La carte Google Maps ne se charge pas. Vérifiez votre clé API.';
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    _mapController = controller;
    print('✅ Google Maps créé avec succès');
    setState(() {
      _errorMessage = null;
    });

    // Vérifier que la carte est bien initialisée
    controller
        .getZoomLevel()
        .then((zoom) {
          print('📍 Zoom initial: $zoom');
        })
        .catchError((error) {
          print('❌ Erreur lors de la création de la carte: $error');
          setState(() {
            _errorMessage = 'Erreur: $error';
          });
        });
  }

  void _updateMarkers(List<Place> places, loc.Location? userLocation) {
    // Éviter les mises à jour inutiles
    if (_lastPlaces.length == places.length &&
        _lastPlaces.every((p) => places.any((np) => np.id == p.id))) {
      return;
    }
    _lastPlaces = places;

    setState(() {
      _markers = places.map((place) {
        return gmaps.Marker(
          markerId: gmaps.MarkerId(place.id),
          position: gmaps.LatLng(place.latitude, place.longitude),
          infoWindow: gmaps.InfoWindow(
            title: place.name,
            snippet: place.description,
          ),
          onTap: () {
            ref.read(mapProvider.notifier).selectPlace(place);
            context.go('/place/${place.id}');
          },
        );
      }).toSet();

      // Ajouter un marqueur pour la position utilisateur
      if (userLocation != null) {
        _markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('user_location'),
            position: gmaps.LatLng(
              userLocation.latitude,
              userLocation.longitude,
            ),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueBlue,
            ),
            infoWindow: const gmaps.InfoWindow(
              title: 'Ma position',
              snippet: 'Position actuelle',
            ),
          ),
        );
      }
    });
  }

  void _updatePolylines(MapRoute? route) {
    // Éviter les mises à jour inutiles
    if (_lastRoute == route) {
      return;
    }
    _lastRoute = route;

    setState(() {
      if (route != null) {
        _polylines = {
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId('route'),
            points: route.coordinates
                .map((coord) => gmaps.LatLng(coord.latitude, coord.longitude))
                .toList(),
            color: AppColors.mapRoute,
            width: 5,
          ),
        };
      } else {
        _polylines = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final locationState = ref.watch(loc.locationProvider);

    // Mettre à jour les marqueurs quand les places changent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers(mapState.places, locationState.currentLocation);
      if (mapState.currentRoute != null) {
        _updatePolylines(mapState.currentRoute);
      }
    });

    // Écouter les changements de position utilisateur pour centrer la carte
    ref.listen(loc.locationProvider.select((state) => state.currentLocation), (
      previous,
      next,
    ) {
      if (next != null && _mapController != null) {
        // Centrer la carte sur la position utilisateur
        _mapController!.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(next.latitude, next.longitude),
            16.0, // Zoom approprié pour voir la position
          ),
        );
        // Mettre à jour la position dans le provider
        ref
            .read(mapProvider.notifier)
            .updateMapPosition(next.latitude, next.longitude, 16.0);
      }
    });

    // Écouter les changements de position pour centrer la carte (pour les lieux sélectionnés)
    ref.listen(mapProvider.select((state) => state.centerPosition), (
      previous,
      next,
    ) {
      if (next != null && _mapController != null) {
        _mapController!.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(next.latitude, next.longitude),
            mapState.zoomLevel,
          ),
        );
      }
    });

    // Position initiale
    final initialPosition = mapState.centerPosition != null
        ? gmaps.LatLng(
            mapState.centerPosition!.latitude,
            mapState.centerPosition!.longitude,
          )
        : gmaps.LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude);

    // Afficher un message d'erreur si la carte ne se charge pas
    if (_errorMessage != null) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de chargement de Google Maps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '⚠️ Vérifiez votre clé API Google Maps',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'La clé doit commencer par "AIzaSy..."',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  '💡 Solution temporaire :\nUtilisez FlutterMap (OpenStreetMap)\nen attendant de corriger la clé API',
                  style: TextStyle(fontSize: 11, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return gmaps.GoogleMap(
      key: ValueKey(
        'google_map_${mapState.places.length}',
      ), // Force la reconstruction si nécessaire
      onMapCreated: _onMapCreated,
      initialCameraPosition: gmaps.CameraPosition(
        target: initialPosition,
        zoom: mapState.zoomLevel.clamp(
          10.0,
          20.0,
        ), // Limiter le zoom pour éviter les problèmes
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: locationState.currentLocation != null,
      myLocationButtonEnabled:
          false, // Désactivé car on utilise le bouton personnalisé
      mapType: gmaps.MapType.normal,
      minMaxZoomPreference: const gmaps.MinMaxZoomPreference(
        10.0,
        20.0,
      ), // Limites de zoom
      onTap: (gmaps.LatLng position) {
        ref.read(mapProvider.notifier).onMapTapped({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      },
      onCameraMoveStarted: () {
        // Optionnel : désactiver les mises à jour pendant le mouvement
      },
      onCameraMove: (gmaps.CameraPosition position) {
        // Ne pas mettre à jour le provider pendant le mouvement pour éviter les problèmes
      },
      onCameraIdle: () {
        // Mettre à jour la position seulement quand le mouvement est terminé
        // Cela évite les problèmes de carte blanche lors du zoom
        if (_mapController != null) {
          _mapController!
              .getZoomLevel()
              .then((zoom) {
                print('📍 Zoom après mouvement: $zoom');
              })
              .catchError((error) {
                print('❌ Erreur lors de la récupération du zoom: $error');
              });
        }
      },
      // Options de la carte
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false, // Désactivé car on utilise les gestes
      liteModeEnabled:
          false, // Désactiver le mode lite pour avoir toutes les fonctionnalités
    );
  }
}
