import 'package:flutter/material.dart' show ThemeMode;
import 'package:sagahelper/core/themes.dart' show allCustomThemes;
import 'package:sagahelper/models/config/persistent_settings.dart';
import 'package:sagahelper/models/config/types.dart' show OperatorDisplayMode;
import 'package:sagahelper/models/filters.dart' show OperatorSortingType;
import 'package:sagahelper/providers/server_provider.dart' show Server;
import 'package:shared_preferences/shared_preferences.dart';

enum ConfigKeys {
  /// Can save either [int] or [Enum]
  currentServer('currentServerIndex'),

  /// Save [bool]
  homeHour12Format('homeHour12Format'),

  /// Save [bool]
  homeShowDate('homeShowDate'),

  /// Save [bool]
  homeShowSeconds('homeShowSeconds'),

  /// Save [bool]
  homeCompactMode('homeCompactMode'),

  /// Save [String]
  nickname('nickname'),

  /// Save [int]
  operatorSearchDelegate('operatorSearchDelegate'),

  /// Can save either [int] or [Enum]
  operatorDisplayMode('operatorDisplayModeIndex'),

  /// Can save either [int] or [Enum]
  operatorSortingType('operatorSortingTypeIndex'),

  /// Save [bool]
  useOperatorSortingReversed('useOperatorSortingReversed'),

  /// Save index [int]
  customTheme('customThemeIndex'),

  /// Can save either [int] or [Enum]
  themeMode('themeModeIndex'),

  /// Save [bool]
  usePureDarkTheme('usePureDarkTheme'),

  /// Save [bool]
  useTranslucentUi('useTranslucentUi'),

  /// Save [bool]
  useClassicDialogBox('useClassicDialogBox'),

  /// Save [bool]
  opInfoMenuShowAdvanced('opInfo_menuShowAdvanced'),

  /// Save [bool]
  homeNotificationRequestAccepted('home_NotificationRequestAccepted'),

  /// Save [bool]
  checkGamedataUpdatesOnStart('settings_checkGamedataUpdatesOnStart'),

  /// Save [bool]
  checkAppUpdatesOnStart('settings_checkAppUpdatesOnStart'),

  /// Save [bool]
  offlineMode('settings_offlineMode');

  final String key;

  const ConfigKeys(this.key);
}

class ConfigManager {
  final SharedPreferencesWithCache _prefs;

  const ConfigManager(this._prefs);

  PersistentSettings loadSettings() {
    final settingNickname = _prefs.getString(ConfigKeys.nickname.key);

    return PersistentSettings(
      currentServer: Server.values[_prefs.getInt(ConfigKeys.currentServer.key) ?? Server.en.index],
      homeCompactMode: _prefs.getBool(ConfigKeys.homeCompactMode.key) ?? false,
      homeHour12Format: _prefs.getBool(ConfigKeys.homeHour12Format.key) ?? false,
      homeShowDate: _prefs.getBool(ConfigKeys.homeShowDate.key) ?? true,
      homeShowSeconds: _prefs.getBool(ConfigKeys.homeShowSeconds.key) ?? false,
      nickname: settingNickname == '' ? null : settingNickname,
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
      checkGamedataUpdatesOnStart:
          _prefs.getBool(ConfigKeys.checkGamedataUpdatesOnStart.key) ?? true,
      checkAppUpdatesOnStart: _prefs.getBool(ConfigKeys.checkAppUpdatesOnStart.key) ?? true,
      offlineMode: _prefs.getBool(ConfigKeys.offlineMode.key) ?? false,
    );
  }

  Future<void> saveSetting(ConfigKeys config, Object value) async {
    switch (value) {
      case Enum _:
        return await _prefs.setInt(config.key, value.index);
      case int _:
        return await _prefs.setInt(config.key, value);
      case double _:
        return await _prefs.setDouble(config.key, value);
      case bool _:
        return await _prefs.setBool(config.key, value);
      case String _:
        return await _prefs.setString(config.key, value);
      case List<String> _:
        return await _prefs.setStringList(config.key, value);
      default:
        throw ArgumentError('Tipo no soportado para SharedPreferences: ${value.runtimeType}');
    }
  }
}
