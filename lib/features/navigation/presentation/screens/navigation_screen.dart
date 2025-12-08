import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import '../../../map/presentation/providers/navigation_provider.dart';
import '../../../map/presentation/widgets/route_info_widget.dart';
import '../../../map/presentation/widgets/direction_steps_widget.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final String? destinationId;
  final double? startLat;
  final double? startLon;

  const NavigationScreen({
    super.key,
    this.destinationId,
    this.startLat,
    this.startLon,
  });

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  late MapController _mapController;
  bool _showDirections = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Calculer l'itinéraire au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.destinationId != null) {
        ref.read(navigationProvider.notifier).calculateRoute(
          destinationId: widget.destinationId!,
          startLat: widget.startLat,
          startLon: widget.startLon,
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Carte avec itinéraire
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: navState.startPoint != null
                  ? LatLng(navState.startPoint!.latitude, 
                          navState.startPoint!.longitude)
                  : LatLng(7.3167, 13.5833),
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'cm.mapdang.app',
              ),
              if (navState.routePolyline != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: navState.routePolyline!
                          .map((coord) => LatLng(coord.latitude, coord.longitude))
                          .toList(),
                      color: AppColors.mapRoute,
                      strokeWidth: 6,
                      borderColor: AppColors.mapRouteBorder,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Marqueur de départ
                  if (navState.startPoint != null)
                    Marker(
                      point: LatLng(
                        navState.startPoint!.latitude,
                        navState.startPoint!.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  // Marqueur de destination
                  if (navState.destination != null)
                    Marker(
                      point: LatLng(
                        navState.destination!.latitude,
                        navState.destination!.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // En-tête avec bouton retour
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => context.navigateBack(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),

          // Informations sur l'itinéraire
          if (navState.currentRoute != null && !_showDirections)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RouteInfoWidget(
                route: navState.currentRoute!,
                transportMode: navState.transportMode,
                onStartNavigation: () {
                  setState(() {
                    _showDirections = true;
                  });
                },
                onShowDirections: () {
                  setState(() {
                    _showDirections = true;
                  });
                },
              ),
            ),

          // Liste des directions
          if (_showDirections && navState.currentRoute != null && navState.currentRoute!.steps != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: DirectionStepsWidget(
                steps: navState.currentRoute!.steps!,
                onClose: () {
                  setState(() {
                    _showDirections = false;
                  });
                },
              ),
            ),

          // Loader pendant le calcul
          if (navState.isCalculating)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Calcul de l\'itinéraire...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Erreur
          if (navState.error != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          navState.error!,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(navigationProvider.notifier).clearError();
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}