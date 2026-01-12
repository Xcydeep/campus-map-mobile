import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
// import '../widgets/map_widget.dart'; // FlutterMap (OpenStreetMap) - désactivé
import '../widgets/google_map_widget.dart'; // Google Maps - activé
import '../widgets/search_bar_widget.dart';
import '../widgets/floating_action_buttons.dart';
import '../widgets/bottom_sheet_places_list.dart';
import '../widgets/network_status_widget.dart';
import '../providers/map_provider.dart';
import '../providers/location_provider.dart';
import '../providers/api_providers.dart';
import '../../../../core/constants/campus_constants.dart';
import '../../domain/entities/place.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? shareToken;

  const MapScreen({super.key, this.shareToken});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();

    // Initialiser la localisation et charger les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getCurrentLocation();

      // Charger les POIs depuis l'API
      ref.refresh(poisProvider);

      // Quand les POIs sont chargés, les appliquer au provider de la carte
      ref.listen<AsyncValue<List<Place>>>(poisProvider, (previous, next) {
        next.whenData((places) {
          if (places.isNotEmpty) {
            ref.read(mapProvider.notifier).setPlaces(places);
            // Centrer sur le campus si pas de position définie
            if (ref.read(mapProvider).centerPosition == null) {
              ref
                  .read(mapProvider.notifier)
                  .updateMapPosition(
                    CampusConstants.campusLatitude,
                    CampusConstants.campusLongitude,
                    16.0,
                  );
            }
          }
        });
      });

      // Si un token de partage est présent, décoder et afficher
      if (widget.shareToken != null) {
        _handleShareToken(widget.shareToken!);
      }
    });
  }

  void _handleShareToken(String token) {
    // TODO: Décoder le token et centrer la carte sur la position partagée
    ref.read(mapProvider.notifier).handleSharedLocation(token);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    //final locationState = ref.watch(locationProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Widget de statut réseau
            const NetworkStatusWidget(),

            // Contenu principal
            Expanded(
              child: Stack(
                children: [
                  // Carte principale - Google Maps
                  const GoogleMapWidget(),
                  // Ancienne carte OpenStreetMap (désactivée)
                  // const MapWidget(),

                  // Barre de recherche en haut
                  Positioned(
                    top: 24,
                    left: 16,
                    right: 16,
                    child: const SearchBarWidget(),
                  ),

                  // Indicateur de connexion hors-ligne
                  if (!mapState.isOnline)
                    Positioned(
                      top: 80,
                      left: 16,
                      right: 16,
                      child: _buildOfflineIndicator(),
                    ),

                  // Boutons d'action flottants
                  Positioned(
                    right: 16,
                    bottom: 120,
                    child: FloatingActionButtons(
                      onMyLocationPressed: () async {
                        // Récupérer la position de l'utilisateur
                        await ref
                            .read(locationProvider.notifier)
                            .getCurrentLocation();

                        // Attendre un peu pour que la position soit mise à jour
                        await Future.delayed(const Duration(milliseconds: 100));

                        // Centrer la carte sur la position de l'utilisateur
                        final locationState = ref.read(locationProvider);
                        if (locationState.currentLocation != null) {
                          ref
                              .read(mapProvider.notifier)
                              .updateMapPosition(
                                locationState.currentLocation!.latitude,
                                locationState.currentLocation!.longitude,
                                16.0, // Zoom approprié
                              );
                        }
                      },
                      onLayersPressed: () {
                        _showLayersBottomSheet(context);
                      },
                      onSchedulePressed: () {
                        context.go('/schedule');
                      },
                    ),
                  ),

                  // Bottom sheet avec liste des lieux si recherche active
                  if (mapState.searchResults.isNotEmpty)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: BottomSheetPlacesList(),
                    ),

                  // Loader pendant le chargement
                  if (mapState.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mode hors-ligne activé',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLayersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Couches de la carte', style: AppTextStyles.h5),
            const SizedBox(height: 20),
            _buildLayerOption('Bâtiments', Icons.business, true, (value) {
              ref.read(mapProvider.notifier).toggleLayer('buildings', value);
            }),
            _buildLayerOption('Points d\'intérêt', Icons.place, true, (value) {
              ref.read(mapProvider.notifier).toggleLayer('poi', value);
            }),
            _buildLayerOption(
              'Itinéraires piétons',
              Icons.directions_walk,
              true,
              (value) {
                ref.read(mapProvider.notifier).toggleLayer('pedestrian', value);
              },
            ),
            _buildLayerOption('Parkings', Icons.local_parking, false, (value) {
              ref.read(mapProvider.notifier).toggleLayer('parking', value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerOption(
    String title,
    IconData icon,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body),
      trailing: Switch(
        value: initialValue,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
