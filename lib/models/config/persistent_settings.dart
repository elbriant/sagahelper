// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  final bool checkGamedataUpdatesOnStart;
  final bool checkAppUpdatesOnStart;

  int get customThemeIndex {
    return allCustomThemes.indexOf(customTheme);
  }

  const PersistentSettings({
    required this.currentServer,
    required this.homeHour12Format,
    required this.homeShowDate,
    required this.homeShowSeconds,
    required this.homeCompactMode,
    this.nickname,
    required this.operatorSearchDelegate,
    required this.operatorDisplayMode,
    required this.operatorSortingType,
    required this.useOperatorSortingReversed,
    required this.customTheme,
    required this.themeMode,
    required this.usePureDarkTheme,
    required this.useTranslucentUi,
    required this.useClassicDialogBox,
    required this.opInfoMenuShowAdvanced,
    required this.homeNotificationRequestAccepted,
    required this.checkGamedataUpdatesOnStart,
    required this.checkAppUpdatesOnStart,
  });

  PersistentSettings copyWith({
    Server? currentServer,
    bool? homeHour12Format,
    bool? homeShowDate,
    bool? homeShowSeconds,
    bool? homeCompactMode,
    String? nickname,
    int? operatorSearchDelegate,
    OperatorDisplayMode? operatorDisplayMode,
    OperatorSortingType? operatorSortingType,
    bool? useOperatorSortingReversed,
    CustomTheme? customTheme,
    ThemeMode? themeMode,
    bool? usePureDarkTheme,
    bool? useTranslucentUi,
    bool? useClassicDialogBox,
    bool? opInfoMenuShowAdvanced,
    bool? homeNotificationRequestAccepted,
    bool? checkGamedataUpdatesOnStart,
    bool? checkAppUpdatesOnStart,
  }) {
    return PersistentSettings(
      currentServer: currentServer ?? this.currentServer,
      homeHour12Format: homeHour12Format ?? this.homeHour12Format,
      homeShowDate: homeShowDate ?? this.homeShowDate,
      homeShowSeconds: homeShowSeconds ?? this.homeShowSeconds,
      homeCompactMode: homeCompactMode ?? this.homeCompactMode,
      nickname: nickname ?? this.nickname,
      operatorSearchDelegate: operatorSearchDelegate ?? this.operatorSearchDelegate,
      operatorDisplayMode: operatorDisplayMode ?? this.operatorDisplayMode,
      operatorSortingType: operatorSortingType ?? this.operatorSortingType,
      useOperatorSortingReversed: useOperatorSortingReversed ?? this.useOperatorSortingReversed,
      customTheme: customTheme ?? this.customTheme,
      themeMode: themeMode ?? this.themeMode,
      usePureDarkTheme: usePureDarkTheme ?? this.usePureDarkTheme,
      useTranslucentUi: useTranslucentUi ?? this.useTranslucentUi,
      useClassicDialogBox: useClassicDialogBox ?? this.useClassicDialogBox,
      opInfoMenuShowAdvanced: opInfoMenuShowAdvanced ?? this.opInfoMenuShowAdvanced,
      homeNotificationRequestAccepted:
          homeNotificationRequestAccepted ?? this.homeNotificationRequestAccepted,
      checkGamedataUpdatesOnStart: checkGamedataUpdatesOnStart ?? this.checkGamedataUpdatesOnStart,
      checkAppUpdatesOnStart: checkAppUpdatesOnStart ?? this.checkAppUpdatesOnStart,
    );
  }
}
