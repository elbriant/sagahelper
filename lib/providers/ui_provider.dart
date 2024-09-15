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