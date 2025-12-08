import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:math';

part 'place.freezed.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    String? description,
    String? address,
    String? building,
    String? floor,
    List<String>? tags,
    List<String>? photos,
    Map<String, dynamic>? openingHours,
    bool? isPMRAccessible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Place;

  const Place._();

  // Méthode pour calculer la distance depuis un point
  double distanceFrom(double lat, double lon) {
    return _calculateDistance(latitude, longitude, lat, lon);
  }

  // Formater la distance de manière lisible
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceInKm.toStringAsFixed(2)} km';
    }
  }

  // Vérifier si le lieu est ouvert maintenant
  bool isOpenNow() {
    if (openingHours == null || openingHours!.isEmpty) return true;
    
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Lundi, 7 = Dimanche
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final todayHours = openingHours![dayOfWeek.toString()];
    if (todayHours == null) return false;
    
    final openTime = todayHours['open'] as String?;
    final closeTime = todayHours['close'] as String?;
    
    if (openTime == null || closeTime == null) return false;
    
    return currentTime.compareTo(openTime) >= 0 && 
           currentTime.compareTo(closeTime) <= 0;
  }
}

// Formule de Haversine pour calculer la distance entre deux points GPS
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // km

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final rLat1 = _toRadians(lat1);
  final rLat2 = _toRadians(lat2);

   final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(rLat1) * cos(rLat2) * sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * asin(sqrt(a));

  return earthRadius * c;
}

double _toRadians(double degree) {
  return degree * (3.141592653589793 / 180);
}