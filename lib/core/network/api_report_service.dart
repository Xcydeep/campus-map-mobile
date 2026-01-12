/// Service API pour les signalements (Reports)

class ApiReportService {
  // Stockage local des signalements (mock en mémoire)
  static final List<Map<String, dynamic>> _mockReports = [
    {
      'id': 'r1',
      'poiId': '1',
      'poiName': 'Amphi 500',
      'message': 'Le projecteur ne fonctionne pas correctement.',
      'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'status': 'pending',
    },
    {
      'id': 'r2',
      'poiId': '3',
      'poiName': 'Restaurant Universitaire',
      'message': 'Horaires incorrects, ferme à 14h.',
      'date': DateTime.now().toIso8601String(),
      'status': 'resolved',
    },
  ];

  /// Envoie un signalement
  static Future<void> sendReport(
    String poiId,
    String poiName,
    String message,
  ) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    final newReport = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'poiId': poiId,
      'poiName': poiName,
      'message': message,
      'date': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    _mockReports.insert(0, newReport);
  }

  /// Récupère tous les signalements
  static Future<List<Map<String, dynamic>>> getReports(String token) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(milliseconds: 500));

    return List<Map<String, dynamic>>.from(_mockReports);
  }

  /// Marque un signalement comme résolu
  static Future<void> resolveReport(String id, String token) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockReports.indexWhere((report) => report['id'] == id);
    if (index != -1) {
      _mockReports[index] = {..._mockReports[index], 'status': 'resolved'};
    }
  }

  /// Supprime un signalement
  static Future<void> deleteReport(String id, String token) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _mockReports.removeWhere((report) => report['id'] == id);
  }
}
