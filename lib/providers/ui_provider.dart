import 'package:flutter/material.dart';
import 'package:docsprts/themes.dart';

class UiProvider extends ChangeNotifier {
  CustomTheme? currentTheme;
  ThemeMode themeMode;
  bool _isUsingPureDark = true;
  bool _useTranslucentUi = true;

  int previewThemeIndexSelected = 0;

  UiProvider ({
    this.currentTheme,
    this.themeMode = ThemeMode.dark,
  });

  bool get isUsingPureDark => _isUsingPureDark;
  bool get useTranslucentUi => _useTranslucentUi;

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
    notifyListeners();
  }

  void togglePureDark (bool state) async {
    _isUsingPureDark = state;
    notifyListeners();
  }

  void toggleTraslucentUi (bool state) async {
    _useTranslucentUi = state;
    notifyListeners();
  }

  void previewThemeSelected (int index) async {
    previewThemeIndexSelected = index;
    notifyListeners();
  }

}