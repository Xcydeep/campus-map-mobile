import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_poi_service.dart';
import '../../../../core/constants/campus_constants.dart';
import '../../domain/entities/place.dart';

/// Provider pour récupérer les POIs depuis l'API ou utiliser les données par défaut
final poisProvider = FutureProvider<List<Place>>((ref) async {
  try {
    final poisData = await ApiPoiService.getPois();

    // Convertir les données brutes en entités Place
    return poisData.map((poi) {
      return Place(
        id: poi['id']?.toString() ?? '',
        name: poi['name'] ?? 'Sans nom',
        category: poi['category'] ?? 'autre',
        latitude: (poi['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (poi['longitude'] as num?)?.toDouble() ?? 0.0,
        description: poi['description'],
        address: poi['address'],
        tags: poi['tags'] != null ? List<String>.from(poi['tags']) : null,
        photos: poi['photos'] != null ? List<String>.from(poi['photos']) : null,
      );
    }).toList();
  } catch (e) {
    // En cas d'erreur, utiliser les POIs par défaut du campus
    print(
      'Impossible de charger les POIs depuis l\'API, utilisation des données par défaut: $e',
    );
    return CampusConstants.defaultCampusPois;
  }
});

/// Provider pour les signalements
final reportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // On retournerait les signalements depuis l'API si c'était implémenté
  return [];
});
