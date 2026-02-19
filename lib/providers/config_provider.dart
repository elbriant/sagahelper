import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/models/config/persistent_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>((ref) {
  throw UnimplementedError('Override with ProviderScope');
});

final configManagerProvider = Provider<ConfigManager>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ConfigManager(prefs);
});

final configProvider = NotifierProvider<ConfigNotifier, PersistentSettings>(
  ConfigNotifier.new,
);

class ConfigNotifier extends Notifier<PersistentSettings> {
  @override
  PersistentSettings build() {
    final manager = ref.read(configManagerProvider);
    return manager.loadSettings();
  }

  Future<void> updateSettings<T>(ConfigKeys config, T value) async {
    final manager = ref.read(configManagerProvider);
    await manager.saveSetting<T>(config, value);
    state = manager.loadSettings();
  }
}
