/// Service API pour gérer les POIs (Points d'intérêt)
import 'package:campus_map_mobile/core/network/api_client.dart';

class ApiPoiService {
  /// Récupère tous les POIs du campus
  static Future<List<Map<String, dynamic>>> getPois() async {
    try {
      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/pois',
        headers: {'Accept': 'application/ld+json'},
      );
      final data = await ApiClient.handleResponse(response);

      // Gérer la réponse JSON-LD
      if (data is Map<String, dynamic> && data.containsKey('hydra:member')) {
        final pois = (data['hydra:member'] as List)
            .cast<Map<String, dynamic>>();
        return pois;
      }

      return [];
    } catch (e) {
      print('Erreur lors de la récupération des POIs: $e');
      rethrow;
    }
  }

  /// Crée un nouveau POI
  static Future<Map<String, dynamic>> createPoi(
    Map<String, dynamic> poiData,
    String token,
  ) async {
    try {
      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/pois',
        method: 'POST',
        headers: {'Authorization': 'Bearer $token'},
        body: poiData,
      );
      return await ApiClient.handleResponse(response);
    } catch (e) {
      print('Erreur lors de la création du POI: $e');
      rethrow;
    }
  }

  /// Met à jour un POI existant
  static Future<Map<String, dynamic>> updatePoi(
    String id,
    Map<String, dynamic> poiData,
    String token,
  ) async {
    try {
      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/pois/$id',
        method: 'PUT',
        headers: {'Authorization': 'Bearer $token'},
        body: poiData,
      );
      return await ApiClient.handleResponse(response);
    } catch (e) {
      print('Erreur lors de la mise à jour du POI: $e');
      rethrow;
    }
  }

  /// Supprime un POI
  static Future<void> deletePoi(String id, String token) async {
    try {
      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/pois/$id',
        method: 'DELETE',
        headers: {'Authorization': 'Bearer $token'},
      );
      await ApiClient.handleResponse(response);
    } catch (e) {
      print('Erreur lors de la suppression du POI: $e');
      rethrow;
    }
  }
}
