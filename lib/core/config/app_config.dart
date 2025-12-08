class AppConfig {
  // Application-wide configuration and constants
  static const String appName = 'Campus Map';

  // Active les logs en mode debug. Mettre à false en production.
  static const bool enableLogging = true;

  // Defaults for map
  static const double defaultLatitude = 48.8566;
  static const double defaultLongitude = 2.3522;
  static const double defaultZoom = 15.0;

  // App info
  static const String appVersion = '1.0.0';
}
