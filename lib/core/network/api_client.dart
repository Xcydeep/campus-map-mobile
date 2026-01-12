import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String osrmApiUrl =
      'https://router.project-osrm.org/route/v1/walking';
  static const int defaultTimeout = 2000; // 2 secondes
  static const int osrmTimeout = 5000; // 5 secondes

  /// Effectue une requête HTTP avec timeout
  static Future<http.Response> fetchWithTimeout(
    String url, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
    int timeout = defaultTimeout,
  }) async {
    final completer = Completer<http.Response>();
    late final Timer timer;

    timer = Timer(Duration(milliseconds: timeout), () {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Request timeout'));
      }
    });

    try {
      final fullHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/ld+json',
        ...?headers,
      };

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: fullHeaders);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: fullHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: fullHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: fullHeaders);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete(response);
      }
      return response;
    } catch (e) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    }
  }

  /// Analyse la réponse HTTP
  static Future<dynamic> handleResponse(http.Response response) async {
    final contentType = response.headers['content-type'] ?? '';

    // Si c'est du HTML, c'est une erreur (page par défaut de Symfony)
    if (contentType.contains('text/html')) {
      throw Exception('Invalid response format: HTML received');
    }

    if (!response.ok) {
      throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode == 204) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }
}

/// Extension pour vérifier si la réponse est OK
extension ResponseExtension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}
