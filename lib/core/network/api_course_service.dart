/// Service API pour gérer les cours
import 'package:campus_map_mobile/core/network/api_client.dart';

class ApiCourseService {
  /// Ajoute un cours à un POI
  static Future<Map<String, dynamic>> addCourse(
    String poiId,
    Map<String, dynamic> courseData,
    String token,
  ) async {
    try {
      final payload = {...courseData, 'poi': '/api/pois/$poiId'};

      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/courses',
        method: 'POST',
        headers: {'Authorization': 'Bearer $token'},
        body: payload,
      );
      return await ApiClient.handleResponse(response);
    } catch (e) {
      print('Erreur lors de l\'ajout du cours: $e');
      rethrow;
    }
  }

  /// Supprime un cours
  static Future<void> deleteCourse(String id, String token) async {
    try {
      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/courses/$id',
        method: 'DELETE',
        headers: {'Authorization': 'Bearer $token'},
      );
      await ApiClient.handleResponse(response);
    } catch (e) {
      print('Erreur lors de la suppression du cours: $e');
      rethrow;
    }
  }

  /// Récupère les cours d'une date spécifique
  static Future<List<Map<String, dynamic>>> getCoursesByDate(
    DateTime date,
  ) async {
    try {
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await ApiClient.fetchWithTimeout(
        '${ApiClient.apiBaseUrl}/courses?date=$formattedDate',
        headers: {'Accept': 'application/ld+json'},
      );
      final data = await ApiClient.handleResponse(response);

      if (data is Map<String, dynamic> && data.containsKey('hydra:member')) {
        return (data['hydra:member'] as List).cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      print('Erreur lors de la récupération des cours: $e');
      rethrow;
    }
  }
}
