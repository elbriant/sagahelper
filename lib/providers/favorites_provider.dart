import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/favorites/favorites_manager.dart';

final favoritesManagerProvider = Provider<FavoritesManager>((ref) {
  throw UnimplementedError('Override with ProviderScope');
});

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final manager = ref.read(favoritesManagerProvider);
    return manager.getFavorites().toSet();
  }

  void toggleFavorite(String opId) {
    final manager = ref.read(favoritesManagerProvider);
    manager.toggleFavorite(opId);
    state = manager.getFavorites().toSet();
  }

  void addFavorite(String opId) {
    final manager = ref.read(favoritesManagerProvider);
    manager.addFavorite(opId);
    state = manager.getFavorites().toSet();
  }

  void removeFavorite(String opId) {
    final manager = ref.read(favoritesManagerProvider);
    manager.removeFavorite(opId);
    state = manager.getFavorites().toSet();
  }

  bool isFavorite(String opId) {
    return state.contains(opId);
  }
}
