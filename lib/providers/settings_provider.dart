import 'package:flutter/material.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagahelper/global_data.dart';

enum DisplayList {
  avatar,
  portrait;

  int toJson() => index;
  static DisplayList? fromJson(int? index) => index != null ? DisplayList.values[index] : null;
}

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
  homeCompactMode('homeCompactMode'),
  sortingOrder('operatorSortingOrder'),
  sortingReversed('operatorSortingReversed');

  const SettingsProviderKeys(
    this.key,
  );
  final String key;
}

class SettingsProvider extends ChangeNotifier {
  static final Map<SettingsProviderKeys, dynamic> _defaultValues = {
    SettingsProviderKeys.currentServer: Servers.en,
    SettingsProviderKeys._operatorSearchDelegate: 2,
    SettingsProviderKeys._operatorDisplay: DisplayList.avatar,
    SettingsProviderKeys.homeHour12Format: false,
    SettingsProviderKeys.homeShowDate: false,
    SettingsProviderKeys.homeShowSeconds: false,
    SettingsProviderKeys.homeCompactMode: false,
    SettingsProviderKeys.sortingOrder: OrderType.rarity,
    SettingsProviderKeys.sortingReversed: false,
  };

  // ----- saved
  Servers currentServer;
  bool homeHour12Format;
  bool homeShowDate;
  bool homeShowSeconds;
  bool homeCompactMode;

  // Operators Page Flags
  int _operatorSearchDelegate;
  DisplayList _operatorDisplay;
  bool opFetched;
  OrderType sortingOrder;
  bool sortingReversed;
  bool operatorIsSearching = false;
  String operatorFilterString = '';
  Map<String, FilterDetail> operatorFilters = {};

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
    this.opFetched = false,
    this.isLoadingAsync = false,
    this.showNotifier = false,
    this.isLoadingHome = false,
    required this.sortingOrder,
    required this.sortingReversed,
    this.loadingString = '',
  });

  factory SettingsProvider.fromConfig(Map configs) {
    final provider = SettingsProvider(
      configs[SettingsProviderKeys._operatorSearchDelegate.key] ??
          _defaultValues[SettingsProviderKeys._operatorSearchDelegate],
      DisplayList.fromJson(configs[SettingsProviderKeys._operatorDisplay.key]) ??
          _defaultValues[SettingsProviderKeys._operatorDisplay],
      currentServer: Servers.fromJson(configs[SettingsProviderKeys.currentServer.key]) ??
          _defaultValues[SettingsProviderKeys.currentServer],
      homeCompactMode: configs[SettingsProviderKeys.homeCompactMode.key] ??
          _defaultValues[SettingsProviderKeys.homeCompactMode],
      homeHour12Format: configs[SettingsProviderKeys.homeHour12Format.key] ??
          _defaultValues[SettingsProviderKeys.homeHour12Format],
      homeShowDate: configs[SettingsProviderKeys.homeShowDate.key] ??
          _defaultValues[SettingsProviderKeys.homeShowDate],
      homeShowSeconds: configs[SettingsProviderKeys.homeShowSeconds.key] ??
          _defaultValues[SettingsProviderKeys.homeShowSeconds],
      sortingOrder: OrderType.fromJson(configs[SettingsProviderKeys.sortingOrder.key]) ??
          _defaultValues[SettingsProviderKeys.sortingOrder],
      sortingReversed: configs[SettingsProviderKeys.sortingReversed.key] ??
          _defaultValues[SettingsProviderKeys.sortingReversed],
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
  bool isLoadingHome;
  void setIsLoadingHome(bool state) {
    isLoadingHome = state;
    updateNotifier();
  }

  bool isLoadingAsync;
  void setIsLoadingAsync(bool state) {
    isLoadingAsync = state;
    updateNotifier();
  }

  String loadingString;
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

  String get currentServerString => currentServer.folderLabel; // should be localized

  int get operatorSearchDelegate => _operatorSearchDelegate;
  set operatorSearchDelegate(value) {
    _operatorSearchDelegate = value;
    notifyListeners();
  }

  DisplayList get operatorDisplay => _operatorDisplay;

  void setDisplayChip(DisplayList chip) {
    if (_operatorDisplay != chip) {
      _operatorDisplay = chip;
      notifyListeners();
    }
  }

  void writeOpPageSettings() async {
    await LocalDataManager.writeConfigMap({
      SettingsProviderKeys._operatorSearchDelegate.key: _operatorSearchDelegate,
      SettingsProviderKeys._operatorDisplay.key: _operatorDisplay.toJson(),
      SettingsProviderKeys.sortingOrder.key: sortingOrder.toJson(),
      SettingsProviderKeys.sortingReversed.key: sortingReversed,
    });
  }

  void changeServer(Servers server) async {
    currentServer = server;
    await LocalDataManager.writeConfigKey(
      SettingsProviderKeys.currentServer.key,
      server.toJson(),
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

  void setOpFetched(bool newValue) {
    opFetched = newValue;
    notifyListeners();
  }

  void setSortingType(OrderType newOrder) {
    if (sortingOrder == newOrder) return;

    sortingOrder = newOrder;
    notifyListeners();
  }

  void setSortingReverse(bool newValue) {
    if (sortingReversed == newValue) return;

    sortingReversed = newValue;
    notifyListeners();
  }

  void setOperatorIsSearching(bool newValue) {
    if (operatorIsSearching == newValue) return;

    operatorIsSearching = newValue;
    notifyListeners();
  }

  void setOperatorFilterString(String newString) {
    if (operatorFilterString == newString) return;

    operatorFilterString = newString;
    notifyListeners();
  }

  void toggleOperatorFilter(String id, String key, FilterType filterType) {
    Map<String, FilterDetail> result = Map.of(operatorFilters);
    if (result.containsKey(id)) {
      if (result[id]!.mode != FilterMode.blacklist) {
        result[id] =
            FilterDetail(key: result[id]!.key, mode: FilterMode.blacklist, type: result[id]!.type);
      } else {
        result.remove(id);
      }
    } else {
      result[id] = FilterDetail(key: key, mode: FilterMode.whitelist, type: filterType);
    }
    operatorFilters = result;
    notifyListeners();
  }

  void clearOperatorFilters() {
    operatorFilters = {};
    notifyListeners();
  }
}
