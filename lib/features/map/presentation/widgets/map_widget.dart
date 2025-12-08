import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/map_provider.dart';
import '../providers/location_provider.dart';
import 'location_marker_widget.dart';
import 'place_marker_widget.dart';

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({super.key});

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final locationState = ref.watch(locationProvider);

    // Écouter les changements de position pour centrer la carte
    ref.listen(mapProvider.select((state) => state.centerPosition), (
      previous,
      next,
    ) {
      if (next != null) {
        final position = next as LatLng;
        _mapController.move(
          position,
          mapState.zoomLevel,
        );
      }
    });

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          AppConfig.defaultLatitude,
          AppConfig.defaultLongitude,
        ),
        initialZoom: AppConfig.defaultZoom,
        minZoom: 12.0,
        maxZoom: 19.0,
        onTap: (tapPosition, point) {
          ref.read(mapProvider.notifier).onMapTapped(point);
        },
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            ref
                .read(mapProvider.notifier)
                .updateMapPosition(
                  position.center.latitude,
                  position.center.longitude,
                  position.zoom,
                );
          }
        },
      ),
      children: [
        // Tuiles de la carte (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'cm.mapdang.app',
          maxZoom: 19,
          tileProvider: mapState.isOnline
              ? NetworkTileProvider()
              : _OfflineTileProvider(),
        ),

        // Couche des bâtiments (si activée)
        if (mapState.activeLayers.contains('buildings'))
          PolygonLayer(
            polygons: mapState.buildings.map((building) {
              return Polygon(
                points: building.coordinates
                    .map((coord) => LatLng(coord.latitude, coord.longitude))
                    .toList(),
                color: AppColors.mapBuilding.withOpacity(0.3),
                borderColor: AppColors.mapBuilding,
                borderStrokeWidth: 2,
              );
            }).toList(),
          ),

        // Couche des itinéraires (si un itinéraire est actif)
        if (mapState.currentRoute != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapState.currentRoute!.coordinates
                    .map((coord) => LatLng(coord.latitude, coord.longitude))
                    .toList(),
                color: AppColors.mapRoute,
                strokeWidth: 5,
                borderColor: AppColors.mapRouteBorder,
                borderStrokeWidth: 2,
              ),
            ],
          ),

        // Marqueurs des lieux (POI)
        if (mapState.activeLayers.contains('poi'))
          MarkerLayer(
            markers: mapState.places.map((place) {
              return Marker(
                point: LatLng(place.latitude, place.longitude),
                width: 40,
                height: 40,
                child: PlaceMarkerWidget(
                  place: place,
                  onTap: () {
                    ref.read(mapProvider.notifier).selectPlace(place);
                    context.go('/place/${place.id}');
                  },
                ),
              );
            }).toList(),
          ),

        // Marqueur de la position utilisateur
        if (locationState.currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  locationState.currentLocation!.latitude,
                  locationState.currentLocation!.longitude,
                ),
                width: 60,
                height: 60,
                child: const LocationMarkerWidget(),
              ),
            ],
          ),

        // Attribution (obligatoire pour OSM)
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}

// Provider de tuiles hors-ligne personnalisé
class _OfflineTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // TODO: Implémenter le chargement depuis le cache local
    // Pour l'instant, retourner une tuile vide
    return const AssetImage('assets/maps/offline_tile.png');
  }
}
