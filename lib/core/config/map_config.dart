/// Configuration pour les services de cartographie
class MapConfig {
  // Google Maps API Key
  // Obtenue depuis: https://console.cloud.google.com/apis/credentials?project=campusmap-un-ngaoundere
  // 
  // NOTE: Cette valeur est à titre de référence uniquement.
  // La clé API est configurée dans AndroidManifest.xml et Info.plist
  static const String googleMapsApiKey = 'AIzaSyAyplRtZb9Vwg_fn9Tf2GDmdTXI3YPWHXo';

  // Mapbox Access Token (si utilisé)
  static const String mapboxAccessToken = '';

  // Type de carte par défaut
  static const MapType defaultMapType = MapType.google; // ou MapType.openstreetmap
}

enum MapType {
  google,
  openstreetmap,
  mapbox,
}

