import 'package:flutter/material.dart';
import 'package:docsprts/themes.dart';
import 'package:docsprts/global_data.dart';

final listAllThemeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

class UiProvider extends ChangeNotifier {
  CustomTheme? currentTheme;
  ThemeMode themeMode;
  bool isUsingPureDark = true;
  bool useTranslucentUi = true;
  int previewThemeIndexSelected = 0;

  final _configs = LocalDataManager();

  UiProvider ({
    this.currentTheme,
    this.themeMode = ThemeMode.dark,
  });

  writeDefaultValues () async {
    return await _configs.writeConfigMap({
      'currentTheme': 0,
      'themeMode': 0,
      'isUsingPureDark': false,
      'useTranslucentUi': false,
      'previewThemeIndexSelected' : 0,
    });
  }

  setDefaultValues () {
    currentTheme = allCustomThemesList[0];
    themeMode = listAllThemeModes[0];
    isUsingPureDark = false;
    useTranslucentUi = false;
    previewThemeIndexSelected = 0;
  }

  loadValues () async {
    return {
      'currentTheme': await _configs.readConfig('currentTheme'),
      'themeMode': await _configs.readConfig('themeMode'),
      'isUsingPureDark': await _configs.readConfig('isUsingPureDark'),
      'useTranslucentUi': await _configs.readConfig('useTranslucentUi'),
      'previewThemeIndexSelected' : await _configs.readConfig('previewThemeIndexSelected'),
    };
  }

  setValues (Map configs) {
    currentTheme = allCustomThemesList[configs['currentTheme']];
    themeMode = listAllThemeModes[configs['themeMode']];
    isUsingPureDark = configs['isUsingPureDark'];
    useTranslucentUi = configs['useTranslucentUi'];
    previewThemeIndexSelected = configs['previewThemeIndexSelected'];
  }

  void changeTheme ({
    required CustomTheme newTheme,
  }) async {
    currentTheme = newTheme;
    notifyListeners();
  }

  void setThemeMode ({
    required ThemeMode newThemeMode
  }) async {
    themeMode = newThemeMode;
    await _configs.writeConfigKey('themeMode', listAllThemeModes.indexOf(newThemeMode));
    notifyListeners();
  }

  void togglePureDark (bool state) async {
    isUsingPureDark = state;
    await _configs.writeConfigKey('isUsingPureDark', state);
    notifyListeners();
  }

  void toggleTraslucentUi (bool state) async {
    useTranslucentUi = state;
    await _configs.writeConfigKey('useTranslucentUi', state);
    notifyListeners();
  }

  void previewThemeSelected (int index) async {
    previewThemeIndexSelected = index;
    await _configs.writeConfigMap({
      'currentTheme': index,
      'previewThemeIndexSelected': index
    });
    notifyListeners();
  }

}