import 'package:flutter/material.dart';
import 'package:sagahelper/themes.dart';
import 'package:sagahelper/global_data.dart';

final listAllThemeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

enum UiProviderKeys {
  currentTheme('currentTheme'),
  themeMode('themeMode'),
  isUsingPureDark('isUsingPureDark'),
  useTranslucentUi('useTranslucentUi'),
  previewThemeIndexSelected('previewThemeIndexSelected'),
  combineWithTheme('combineWithTheme');

  const UiProviderKeys(
    this.key,
  );
  final String key;
}

class UiProvider extends ChangeNotifier {
  static final Map<UiProviderKeys, dynamic> _defaultValues = {
    UiProviderKeys.currentTheme: 0,
    UiProviderKeys.themeMode: 0,
    UiProviderKeys.isUsingPureDark: false,
    UiProviderKeys.useTranslucentUi: false,
    UiProviderKeys.previewThemeIndexSelected: 0,
    UiProviderKeys.combineWithTheme: true,
  };

  // saved configs
  CustomTheme currentTheme;
  ThemeMode themeMode;
  bool isUsingPureDark;
  bool useTranslucentUi;
  int previewThemeIndexSelected;

  // dialog Box
  bool combineWithTheme;

  //not save
  int _currentHomePageIndx = 0;
  int get currentHomePageIndx => _currentHomePageIndx;
  set currentHomePageIndx(index) {
    _currentHomePageIndx = index;
    notifyListeners();
  }

  UiProvider({
    required this.currentTheme,
    required this.themeMode,
    required this.isUsingPureDark,
    required this.useTranslucentUi,
    required this.previewThemeIndexSelected,
    required this.combineWithTheme,
  });

  factory UiProvider.fromConfig(Map configs) {
    return UiProvider(
      currentTheme: allCustomThemesList[
          configs[UiProviderKeys.currentTheme.key] ?? _defaultValues[UiProviderKeys.currentTheme]],
      themeMode: listAllThemeModes[
          configs[UiProviderKeys.themeMode.key] ?? _defaultValues[UiProviderKeys.themeMode]],
      isUsingPureDark: configs[UiProviderKeys.isUsingPureDark.key] ??
          _defaultValues[UiProviderKeys.isUsingPureDark],
      previewThemeIndexSelected: configs[UiProviderKeys.previewThemeIndexSelected.key] ??
          _defaultValues[UiProviderKeys.previewThemeIndexSelected],
      useTranslucentUi: configs[UiProviderKeys.useTranslucentUi.key] ??
          _defaultValues[UiProviderKeys.useTranslucentUi],
      combineWithTheme: configs[UiProviderKeys.combineWithTheme] ??
          _defaultValues[UiProviderKeys.combineWithTheme],
    );
  }

  static Future<Map<String, dynamic>> loadValues() async {
    return await LocalDataManager.readConfigMap(
      UiProviderKeys.values.map((e) => e.key).toList(),
    );
  }

  Future<void> changeTheme({
    required CustomTheme newTheme,
  }) async {
    currentTheme = newTheme;
    notifyListeners();
  }

  void setThemeMode({
    required ThemeMode newThemeMode,
  }) async {
    themeMode = newThemeMode;
    await LocalDataManager.writeConfigKey(
      UiProviderKeys.themeMode.key,
      listAllThemeModes.indexOf(newThemeMode),
    );
    notifyListeners();
  }

  void togglePureDark(bool state) async {
    isUsingPureDark = state;
    await LocalDataManager.writeConfigKey(
      UiProviderKeys.isUsingPureDark.key,
      state,
    );
    notifyListeners();
  }

  void toggleTraslucentUi(bool state) async {
    useTranslucentUi = state;
    await LocalDataManager.writeConfigKey(
      UiProviderKeys.useTranslucentUi.key,
      state,
    );
    notifyListeners();
  }

  void previewThemeSelected(int index) async {
    previewThemeIndexSelected = index;
    await LocalDataManager.writeConfigMap({
      UiProviderKeys.currentTheme.key: index,
      UiProviderKeys.previewThemeIndexSelected.key: index,
    });
    notifyListeners();
  }

  void setCombineWithTheme(bool newValue) async {
    combineWithTheme = newValue;
    await LocalDataManager.writeConfigKey(
      UiProviderKeys.combineWithTheme.key,
      newValue,
    );
    notifyListeners();
  }
}
