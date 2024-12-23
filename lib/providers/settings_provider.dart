import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagahelper/global_data.dart';

const List<String> serverList = ['en', 'cn', 'jp', 'kr', 'tw'];
const List<String> displayList = ['avatar', 'portrait'];

enum PrefsFlags {
  menuShowAdvanced('opInfo_menushowadvanced');

  const PrefsFlags(this.key);
  final String key;
}

enum SettingsProviderKeys {
  currentServer('currentServer'),
  _operatorSearchDelegate('_operatorSearchDelegate'),
  _operatorDisplay('_operatorDisplay'),
  homeHour12Format('homeHour12Format'),
  homeShowDate('homeShowDate'),
  homeShowSeconds('homeShowSeconds'),
  homeCompactMode('homeCompactMode');

  const SettingsProviderKeys(
    this.key,
  );
  final String key;
}

class SettingsProvider extends ChangeNotifier {
  static final Map<SettingsProviderKeys, dynamic> _defaultValues = {
    SettingsProviderKeys.currentServer: 0,
    SettingsProviderKeys._operatorSearchDelegate: 2,
    SettingsProviderKeys._operatorDisplay: 0,
    SettingsProviderKeys.homeHour12Format: false,
    SettingsProviderKeys.homeShowDate: false,
    SettingsProviderKeys.homeShowSeconds: false,
    SettingsProviderKeys.homeCompactMode: false,
  };

  // ----- saved
  int currentServer;
  bool homeHour12Format;
  bool homeShowDate;
  bool homeShowSeconds;
  bool homeCompactMode;

  // Operators Page Flags
  int _operatorSearchDelegate;
  int _operatorDisplay;
  bool opFetched = false;
  // data
  //TODO add configuration to change nickname
  String? nickname;

  SettingsProvider(
    this._operatorSearchDelegate,
    this._operatorDisplay, {
    required this.currentServer,
    required this.homeHour12Format,
    required this.homeShowDate,
    required this.homeShowSeconds,
    required this.homeCompactMode,
    this.nickname,
  });

  factory SettingsProvider.fromConfig(Map configs) {
    final provider = SettingsProvider(
      configs[SettingsProviderKeys._operatorSearchDelegate.key] ??
          _defaultValues[SettingsProviderKeys._operatorSearchDelegate],
      configs[SettingsProviderKeys._operatorDisplay.key] ??
          _defaultValues[SettingsProviderKeys._operatorDisplay],
      currentServer: configs[SettingsProviderKeys.currentServer.key] ??
          _defaultValues[SettingsProviderKeys.currentServer],
      homeCompactMode: configs[SettingsProviderKeys.homeCompactMode.key] ??
          _defaultValues[SettingsProviderKeys.homeCompactMode],
      homeHour12Format: configs[SettingsProviderKeys.homeHour12Format.key] ??
          _defaultValues[SettingsProviderKeys.homeHour12Format],
      homeShowDate: configs[SettingsProviderKeys.homeShowDate.key] ??
          _defaultValues[SettingsProviderKeys.homeShowDate],
      homeShowSeconds: configs[SettingsProviderKeys.homeShowSeconds.key] ??
          _defaultValues[SettingsProviderKeys.homeShowSeconds],
    );
    provider.loadSharedPreferences();
    return provider;
  }

  static Future<Map<String, dynamic>> loadValues() async {
    return await LocalDataManager.readConfigMap(
      SettingsProviderKeys.values.map((e) => e.key).toList(),
    );
  }

  // ------ tempo
  bool isLoadingHome = false;
  void setIsLoadingHome(bool state) {
    isLoadingHome = state;
    updateNotifier();
  }

  bool isLoadingAsync = false;
  void setIsLoadingAsync(bool state) {
    isLoadingAsync = state;
    updateNotifier();
  }

  String loadingString = 'test: test';
  void setLoadingString(String string) {
    loadingString = string;
    notifyListeners();
  }

  bool showNotifier = false;
  void updateNotifier() {
    if (isLoadingAsync || isLoadingHome) {
      // here other optional loadings
      showNotifier = true;
    } else {
      showNotifier = false;
    }
    notifyListeners();
  }

  Map prefs = {
    PrefsFlags.menuShowAdvanced: false,
  };

  static SharedPreferencesWithCache? _cachedPrefs;

  static Future<void> sharedPreferencesInit() async {
    if (_cachedPrefs != null) return;
    final allowList = Set<String>.from(PrefsFlags.values.map((e) => e.key));

    _cachedPrefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        // When an allowlist is included, any keys that aren't included cannot be used.
        allowList: allowList,
      ),
    );

    return;
  }

  void loadSharedPreferences() {
    for (PrefsFlags flag in PrefsFlags.values) {
      if (_cachedPrefs!.get(flag.key) == null) continue;
      prefs[flag] = _cachedPrefs!.get(flag.key);
    }
  }

  void sharedPreferencesClear() async {
    await _cachedPrefs?.clear();
    _cachedPrefs = null;
  }

  void setAndSaveBoolPref(PrefsFlags flag, bool value) async {
    if (_cachedPrefs == null) {
      throw const FormatException('prefs not initialized');
    }
    prefs[flag] = value;
    await _cachedPrefs!.setBool(flag.key, value);
    notifyListeners();
  }

  String get currentServerString => serverList[currentServer];
  int get operatorSearchDelegate => _operatorSearchDelegate;
  set operatorSearchDelegate(value) {
    _operatorSearchDelegate = value;
    notifyListeners();
  }

  String getDisplayChipStr() => displayList[_operatorDisplay];
  bool getDisplayChip(String chip) {
    return displayList.indexOf(chip) == _operatorDisplay;
  }

  void setDisplayChip(String chip) {
    if (displayList.indexOf(chip) != _operatorDisplay) {
      _operatorDisplay = displayList.indexOf(chip);
      notifyListeners();
    }
  }

  void writeOpPageSettings() async {
    await LocalDataManager.writeConfigMap({
      SettingsProviderKeys._operatorSearchDelegate.key: _operatorSearchDelegate,
      SettingsProviderKeys._operatorDisplay.key: _operatorDisplay,
    });
  }

  void changeServer(int server) async {
    currentServer = server;
    await LocalDataManager.writeConfigKey(
      SettingsProviderKeys.currentServer.key,
      server,
    );
    notifyListeners();
  }

  void setHourFormat(bool value) async {
    homeHour12Format = value;
    await LocalDataManager.writeConfigKey(
      SettingsProviderKeys.homeHour12Format.key,
      value,
    );
    notifyListeners();
  }

  void sethomeShowDate(bool value) async {
    homeShowDate = value;
    await LocalDataManager.writeConfigKey(
      SettingsProviderKeys.homeShowDate.key,
      value,
    );
    notifyListeners();
  }

  void sethomeShowSeconds(bool value) async {
    homeShowSeconds = value;
    await LocalDataManager.writeConfigKey(
      SettingsProviderKeys.homeShowSeconds.key,
      value,
    );
    notifyListeners();
  }

  void sethomeCompactMode(bool value) async {
    homeCompactMode = value;
    await LocalDataManager.writeConfigKey(
      SettingsProviderKeys.homeCompactMode.key,
      value,
    );
    notifyListeners();
  }
}
