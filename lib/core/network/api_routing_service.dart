/// Service API pour les itinéraires (Routing)
import 'package:campus_map_mobile/core/network/api_client.dart';

class ApiRoutingService {
  /// Récupère un itinéraire entre deux points
  static Future<Map<String, dynamic>> getItinerary(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final url =
          '${ApiClient.osrmApiUrl}/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson&steps=true';

      final response = await ApiClient.fetchWithTimeout(
        url,
        timeout: ApiClient.osrmTimeout,
      );

      final data = await ApiClient.handleResponse(response);

      if (data is! Map<String, dynamic> ||
          !data.containsKey('routes') ||
          (data['routes'] as List).isEmpty) {
        throw Exception('Aucun itinéraire trouvé');
      }

      final route = (data['routes'] as List)[0] as Map<String, dynamic>;

      // Extraire les coordonnées du chemin
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = (geometry['coordinates'] as List)
          .map(
            (coord) => {
              'latitude': (coord as List)[1],
              'longitude': (coord)[0],
            },
          )
          .toList();

      // Extraire les étapes
      final legs = (route['legs'] as List)[0] as Map<String, dynamic>;
      final stepsList = ((legs['steps'] as List? ?? [])).map((step) {
        final stepData = step as Map<String, dynamic>;
        final maneuver = stepData['maneuver'] as Map<String, dynamic>?;
        final distance = stepData['distance'] as num? ?? 0;
        final duration = stepData['duration'] as num? ?? 0;

        return {
          'instruction': maneuver?['type'] == 'arrive'
              ? 'Vous êtes arrivé !'
              : (stepData['name'] ?? maneuver?['type'] ?? 'Direction'),
          'distance': _formatDistance(distance.toDouble()),
          'duration': '${(duration / 60).ceil()} min',
        };
      }).toList();

      // Ajouter le point de départ
      final totalDistance = route['distance'] as num? ?? 0;
      final totalDuration = route['duration'] as num? ?? 0;
      stepsList.insert(0, {
        'instruction': 'Départ',
        'distance': _formatDistance(totalDistance.toDouble()),
        'duration': '${(totalDuration / 60).ceil()} min',
      });

      return {
        'path': coordinates,
        'steps': stepsList,
        'distance': totalDistance,
        'duration': totalDuration,
      };
    } catch (e) {
      print('Erreur itinéraire: $e');
      // Fallback : Ligne droite si OSRM échoue
      return {
        'path': [
          {'latitude': startLat, 'longitude': startLng},
          {'latitude': endLat, 'longitude': endLng},
        ],
        'steps': [
          {
            'instruction':
                'Service itinéraire indisponible - Mode vol d\'oiseau',
            'distance': 'N/A',
            'duration': 'N/A',
          },
        ],
        'distance': 0,
        'duration': 0,
      };
    }
  }

  /// Formate une distance en km ou m
  static String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
