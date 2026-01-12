// ignore_for_file: constant_pattern_never_matches_value_type

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfoService {
  static final Connectivity _connectivity = Connectivity();

  /// Vérifie si l'appareil est connecté à Internet
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Erreur lors de la vérification de la connectivité: $e');
      return false;
    }
  }

  /// Écoute les changements de connexion
  static Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  /// Obtient le type de connexion actuel
  static Future<String> getConnectionType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      switch (connectivityResult) {
        case ConnectivityResult.mobile:
          return 'Mobile (4G/5G)';
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        default:
          return 'Non connecté';
      }
    } catch (e) {
      return 'Inconnu';
    }
  }
}
