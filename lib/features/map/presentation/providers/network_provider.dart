import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_info_service.dart';

/// Provider pour vérifier la connectivité réseau
final networkConnectedProvider = FutureProvider<bool>((ref) async {
  return await NetworkInfoService.isConnected();
});

/// Provider pour écouter les changements de connexion en temps réel
final networkStatusStreamProvider = StreamProvider<bool>((ref) {
  return NetworkInfoService.connectionStatusStream;
});

/// Provider pour obtenir le type de connexion
final connectionTypeProvider = FutureProvider<String>((ref) async {
  return await NetworkInfoService.getConnectionType();
});
