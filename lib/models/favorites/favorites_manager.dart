import 'package:hive_ce/hive.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';

class FavoritesManager {
  static const String _boxName = 'favorites';
  static const String _favoritesKey = 'favorite_operators';

  late Box _box;

  Future<void> init() async {
    Hive.init(LocalDataManager.local.path);
    _box = await Hive.openBox(_boxName);
  }

  List<String> getFavorites() {
    final raw = _box.get(_favoritesKey, defaultValue: <String>[]);
    return List<String>.from(raw);
  }

  Future<void> addFavorite(String opId) async {
    final favorites = getFavorites();
    if (!favorites.contains(opId)) {
      favorites.add(opId);
      await _box.put(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String opId) async {
    final favorites = getFavorites();
    favorites.remove(opId);
    await _box.put(_favoritesKey, favorites);
  }

  Future<void> toggleFavorite(String opId) async {
    final favorites = getFavorites();
    if (favorites.contains(opId)) {
      favorites.remove(opId);
    } else {
      favorites.add(opId);
    }
    await _box.put(_favoritesKey, favorites);
  }

  bool isFavorite(String opId) {
    return getFavorites().contains(opId);
  }
}
