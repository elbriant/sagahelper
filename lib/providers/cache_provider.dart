import 'package:provider/provider.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';

class CacheProvider extends ChangeNotifier {
  List<Operator>? cachedListOperator;
  Servers? cachedListOperatorServer;
  String? cachedListOperatorVersion;
  Map<String, dynamic>? cachedRangeTable;
  Map<String, dynamic>? cachedSkillTable;
  Map<String, dynamic>? cachedModInfoTable;
  Map<String, dynamic>? cachedModStatsTable;
  Map<String, dynamic>? cachedBaseSkillTable;
  Map<String, dynamic>? cachedTeamTable;
  Map<String, dynamic>? cachedCharPatch;
  Map<String, dynamic>? cachedCharMeta;
  Map<String, dynamic>? cachedGamedataConst;
  Map<String, dynamic>? cachedCharTable;
  Map<String, dynamic>? cachedGachaTable;

  /// just to know if variables are cached
  /// if you want to know if is cached last version/current server
  /// consider doing it with the other providers too
  bool operatorsDataCached = false;

  void operatorsDataCache({
    required List<Operator> listOperator,
    required Servers listOperatorServer,
    required String listOperatorVersion,
    required Map<String, dynamic> rangeTable,
    required Map<String, dynamic> skillTable,
    required Map<String, dynamic> modTable,
    required Map<String, dynamic> baseSkillTable,
    required Map<String, dynamic> modStatsTable,
    required Map<String, dynamic> teamTable,
    required Map<String, dynamic> charPatch,
    required Map<String, dynamic> charMeta,
    required Map<String, dynamic> gamedataConst,
    required Map<String, dynamic> charTable,
    required Map<String, dynamic> gachaTable,
  }) {
    cachedListOperator = listOperator;
    cachedListOperatorServer = listOperatorServer;
    cachedListOperatorVersion = listOperatorVersion;
    cachedRangeTable = rangeTable;
    cachedSkillTable = skillTable;
    cachedModInfoTable = modTable;
    cachedBaseSkillTable = baseSkillTable;
    cachedModStatsTable = modStatsTable;
    cachedTeamTable = teamTable;
    cachedCharPatch = charPatch;
    cachedCharMeta = charMeta;
    cachedGamedataConst = gamedataConst;
    cachedCharTable = charTable;
    cachedGachaTable = gachaTable;

    operatorsDataCached = true;
    notifyListeners();
  }

  void operatorDataUnCache() {
    cachedListOperator = null;
    cachedListOperatorServer = null;
    cachedListOperatorVersion = null;
    cachedRangeTable = null;
    cachedSkillTable = null;
    cachedModInfoTable = null;
    cachedBaseSkillTable = null;
    cachedModStatsTable = null;
    cachedTeamTable = null;
    cachedCharPatch = null;
    cachedCharMeta = null;
    cachedGamedataConst = null;
    cachedCharTable = null;
    cachedGachaTable = null;

    if (NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().opFetched == true) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setOpFetched(false);
    }

    operatorsDataCached = false;
    notifyListeners();
  }

  void unCacheAll() {
    operatorDataUnCache();
    setStageTable(null);
  }

  Map<String, dynamic>? cachedStageTable;
  void setStageTable(Map<String, dynamic>? response) {
    cachedStageTable = response;
    notifyListeners();
  }
}
