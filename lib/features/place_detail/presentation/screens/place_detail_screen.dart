import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import '../../../map/presentation/widgets/place_info_card.dart';
import '../../../map/presentation/widgets/place_photos_carousel.dart';
import '../../../map/presentation/widgets/place_actions_widget.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  @override
  void initState() {
    super.initState();

    // Charger les détails du lieu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(placeDetailProvider.notifier).loadPlace(widget.placeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final placeState = ref.watch(placeDetailProvider);

    if (placeState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (placeState.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                placeState.error!,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.navigateBack(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final place = placeState.place;
    if (place == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lieu non trouvé')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar avec image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: place.photos != null && place.photos!.isNotEmpty
                  ? PlacePhotosCarousel(photos: place.photos!)
                  : Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.place,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
            ),
            leading: IconButton(
              onPressed: () => context.navigateBack(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _sharePlace(place);
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.share, color: Colors.black),
                ),
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Informations principales
                PlaceInfoCard(place: place),

                // Actions
                PlaceActionsWidget(
                  place: place,
                  onNavigate: () {
                    context.navigateToNavigation(destinationId: place.id);
                  },
                  onShare: () => _sharePlace(place),
                  onReport: () => _showReportDialog(context, place),
                ),

                // Horaires d'ouverture
                if (place.openingHours != null)
                  _buildOpeningHoursCard(place.openingHours!),

                // Tags
                if (place.tags != null && place.tags!.isNotEmpty)
                  _buildTagsCard(place.tags!),

                // Cours à proximité (si applicable)
                _buildNearbyCourses(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursCard(Map<String, dynamic> openingHours) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Horaires d\'ouverture', style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: 16),
            ...openingHours.entries.map((entry) {
              final day = _getDayName(int.parse(entry.key));
              final hours = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day, style: AppTextStyles.body),
                    Text(
                      '${hours['open']} - ${hours['close']}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCard(List<String> tags) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Caractéristiques', style: AppTextStyles.h6),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return Chip(
                  label: Text(tag, style: AppTextStyles.categoryChip),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyCourses() {
    // TODO: Charger les cours à proximité
    return const SizedBox.shrink();
  }

  String _getDayName(int day) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return days[day - 1];
  }

  void _sharePlace(dynamic place) {
    // Générer un lien de partage
    final shareText =
        '''
${place.name}
${place.description ?? ''}

📍 ${place.address ?? 'Université de Ngaoundéré'}

Voir sur MapDang: https://mapdang.cm/place/${place.id}
    '''
            .trim();

    Share.share(shareText);
  }

  void _showReportDialog(BuildContext context, dynamic place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Informations incorrectes'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('incorrect_info');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_off),
              title: const Text('Mauvaise localisation'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('wrong_location');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Photos inappropriées'),
              onTap: () {
                Navigator.pop(context);
                _submitReport('inappropriate_photos');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _submitReport(String reason) {
    // TODO: Envoyer le signalement au backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signalement envoyé. Merci!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// Provider pour les détails du lieu (à créer)
// Simple placeholder provider and state for place details
final placeDetailProvider =
    StateNotifierProvider<PlaceDetailNotifier, PlaceDetailState>((ref) {
      return PlaceDetailNotifier();
    });

class PlaceDetailNotifier extends StateNotifier<PlaceDetailState> {
  PlaceDetailNotifier() : super(PlaceDetailState());

  void loadPlace(String placeId) {
    // TODO: Charger les détails du lieu depuis le backend
  }
}

class PlaceDetailState {
  final dynamic place;
  final bool isLoading;
  final String? error;

  PlaceDetailState({this.place, this.isLoading = false, this.error});
}
