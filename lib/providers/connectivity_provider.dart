import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/config_provider.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isConnectedProvider = Provider<bool>((ref) {
  final asyncResults = ref.watch(connectivityProvider);
  return asyncResults.when(
    data: (results) => results.isNotEmpty && !results.contains(ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Effective connectivity: false when real connectivity is false OR when manual offline mode is on.
final effectiveIsConnectedProvider = Provider<bool>((ref) {
  final isConnected = ref.watch(isConnectedProvider);
  final offlineMode = ref.watch(configProvider.select((p) => p.offlineMode));
  return isConnected && !offlineMode;
});
