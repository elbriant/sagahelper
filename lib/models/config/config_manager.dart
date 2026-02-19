import 'package:flutter/material.dart' show ThemeMode;
import 'package:sagahelper/core/themes.dart' show allCustomThemes;
import 'package:sagahelper/models/config/persistent_settings.dart';
import 'package:sagahelper/models/config/types.dart' show OperatorDisplayMode;
import 'package:sagahelper/models/filters.dart' show OperatorSortingType;
import 'package:sagahelper/providers/server_provider.dart' show Server;
import 'package:shared_preferences/shared_preferences.dart';

bool isSaveableType(Type type) {
  return type is Enum;
}

enum ConfigKeys {
  currentServer('currentServerIndex'),
  homeHour12Format('homeHour12Format'),
  homeShowDate('homeShowDate'),
  homeShowSeconds('homeShowSeconds'),
  homeCompactMode('homeCompactMode'),
  nickname('nickname'),

  operatorSearchDelegate('operatorSearchDelegate'),
  operatorDisplayMode('operatorDisplayModeIndex'),
  operatorSortingType('operatorSortingTypeIndex'),
  useOperatorSortingReversed('useOperatorSortingReversed'),

  customTheme('customThemeIndex'),
  themeMode('themeModeIndex'),
  usePureDarkTheme('usePureDarkTheme'),
  useTranslucentUi('useTranslucentUi'),
  useClassicDialogBox('useClassicDialogBox'),

  opInfoMenuShowAdvanced('opInfo_menuShowAdvanced'),
  homeNotificationRequestAccepted('home_NotificationRequestAccepted');

  final String key;

  const ConfigKeys(this.key);
}

class ConfigManager {
  final SharedPreferencesWithCache _prefs;

  const ConfigManager(this._prefs);

  PersistentSettings loadSettings() {
    return PersistentSettings(
      currentServer: Server.values[_prefs.getInt(ConfigKeys.currentServer.key) ?? Server.en.index],
      homeCompactMode: _prefs.getBool(ConfigKeys.homeCompactMode.key) ?? false,
      homeHour12Format: _prefs.getBool(ConfigKeys.homeHour12Format.key) ?? false,
      homeShowDate: _prefs.getBool(ConfigKeys.homeShowDate.key) ?? true,
      homeShowSeconds: _prefs.getBool(ConfigKeys.homeShowSeconds.key) ?? false,
      nickname: _prefs.getString(ConfigKeys.nickname.key),
      operatorDisplayMode: OperatorDisplayMode.values[
          _prefs.getInt(ConfigKeys.operatorDisplayMode.key) ?? OperatorDisplayMode.avatar.index],
      operatorSearchDelegate: _prefs.getInt(ConfigKeys.operatorSearchDelegate.key) ?? 4,
      operatorSortingType: OperatorSortingType.values[
          _prefs.getInt(ConfigKeys.operatorSortingType.key) ?? OperatorSortingType.rarity.index],
      useOperatorSortingReversed:
          _prefs.getBool(ConfigKeys.useOperatorSortingReversed.key) ?? false,
      customTheme: allCustomThemes[_prefs.getInt(ConfigKeys.customTheme.key) ?? 0],
      themeMode:
          ThemeMode.values[_prefs.getInt(ConfigKeys.themeMode.key) ?? ThemeMode.system.index],
      useClassicDialogBox: _prefs.getBool(ConfigKeys.useClassicDialogBox.key) ?? false,
      usePureDarkTheme: _prefs.getBool(ConfigKeys.usePureDarkTheme.key) ?? false,
      useTranslucentUi: _prefs.getBool(ConfigKeys.useTranslucentUi.key) ?? false,
      homeNotificationRequestAccepted:
          _prefs.getBool(ConfigKeys.homeNotificationRequestAccepted.key) ?? false,
      opInfoMenuShowAdvanced: _prefs.getBool(ConfigKeys.opInfoMenuShowAdvanced.key) ?? false,
    );
  }

  Future<void> saveSetting<T>(ConfigKeys config, T value) async {
    switch (T) {
      case const (Enum):
        return await _prefs.setInt(config.key, (value as Enum).index);
      case const (int):
        return await _prefs.setInt(config.key, value as int);
      case const (double):
        return await _prefs.setDouble(config.key, value as double);
      case const (bool):
        return await _prefs.setBool(config.key, value as bool);
      case const (String):
        return await _prefs.setString(config.key, value as String);
      case const (List<String>):
        return await _prefs.setStringList(config.key, value as List<String>);
      default:
        throw ArgumentError('Tipo no soportado para SharedPreferences: $T');
    }
  }
}
