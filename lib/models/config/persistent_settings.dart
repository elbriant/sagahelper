import 'package:flutter/material.dart';
import 'package:sagahelper/core/themes.dart' show allCustomThemes, CustomTheme;
import 'package:sagahelper/models/config/types.dart' show OperatorDisplayMode;
import 'package:sagahelper/models/filters.dart' show OperatorSortingType;
import 'package:sagahelper/providers/server_provider.dart' show Server;

@immutable
class PersistentSettings {
  // Settings related
  final Server currentServer;
  final bool homeHour12Format;
  final bool homeShowDate;
  final bool homeShowSeconds;
  final bool homeCompactMode;
  final String? nickname;

  // Operator page related
  final int operatorSearchDelegate;
  final OperatorDisplayMode operatorDisplayMode;
  final OperatorSortingType operatorSortingType;
  final bool useOperatorSortingReversed;

  // Ui related
  final CustomTheme customTheme;
  final ThemeMode themeMode;
  final bool usePureDarkTheme;
  final bool useTranslucentUi;
  final bool useClassicDialogBox;

  // optional utils settings
  final bool opInfoMenuShowAdvanced;
  final bool homeNotificationRequestAccepted;

  int get customThemeIndex {
    return allCustomThemes.indexOf(customTheme);
  }

  const PersistentSettings({
    required this.themeMode,
    required this.customTheme,
    required this.useClassicDialogBox,
    required this.usePureDarkTheme,
    required this.useTranslucentUi,
    required this.currentServer,
    required this.homeCompactMode,
    required this.homeHour12Format,
    required this.homeShowDate,
    required this.homeShowSeconds,
    required this.operatorDisplayMode,
    required this.operatorSearchDelegate,
    required this.operatorSortingType,
    required this.useOperatorSortingReversed,
    required this.homeNotificationRequestAccepted,
    required this.opInfoMenuShowAdvanced,
    this.nickname,
  });

  PersistentSettings copyWith({
    ThemeMode? themeMode,
    CustomTheme? customTheme,
    bool? useClassicDialogBox,
    bool? usePureDarkTheme,
    bool? useTranslucentUi,
    Server? currentServer,
    bool? homeCompactMode,
    bool? homeHour12Format,
    bool? homeShowDate,
    bool? homeShowSeconds,
    OperatorDisplayMode? operatorDisplayMode,
    int? operatorSearchDelegate,
    OperatorSortingType? operatorSortingType,
    bool? useOperatorSortingReversed,
    String? nickname,
    bool? homeNotificationRequestAccepted,
    bool? opInfoMenuShowAdvanced,
  }) {
    return PersistentSettings(
      themeMode: themeMode ?? this.themeMode,
      customTheme: customTheme ?? this.customTheme,
      useClassicDialogBox: useClassicDialogBox ?? this.useClassicDialogBox,
      usePureDarkTheme: usePureDarkTheme ?? this.usePureDarkTheme,
      useTranslucentUi: useTranslucentUi ?? this.useTranslucentUi,
      currentServer: currentServer ?? this.currentServer,
      homeCompactMode: homeCompactMode ?? this.homeCompactMode,
      homeHour12Format: homeHour12Format ?? this.homeHour12Format,
      homeShowDate: homeShowDate ?? this.homeShowDate,
      homeShowSeconds: homeShowSeconds ?? this.homeShowSeconds,
      operatorDisplayMode: operatorDisplayMode ?? this.operatorDisplayMode,
      operatorSearchDelegate: operatorSearchDelegate ?? this.operatorSearchDelegate,
      operatorSortingType: operatorSortingType ?? this.operatorSortingType,
      useOperatorSortingReversed: useOperatorSortingReversed ?? this.useOperatorSortingReversed,
      nickname: nickname ?? this.nickname,
      homeNotificationRequestAccepted: opInfoMenuShowAdvanced ?? this.opInfoMenuShowAdvanced,
      opInfoMenuShowAdvanced: opInfoMenuShowAdvanced ?? this.opInfoMenuShowAdvanced,
    );
  }
}
