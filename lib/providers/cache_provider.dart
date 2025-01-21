import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
// import 'package:provider/provider.dart';

class CacheProvider extends ChangeNotifier {
  List<Operator>? cachedListOperator;
  Servers? cachedListOperatorServer;
  String? cachedListOperatorVersion;
  Map<String, dynamic>? cachedRangeTable;
  Map<String, dynamic>? cachedSkillTable;
  Map<String, dynamic>? cachedModTable;
  Map<String, dynamic>? cachedModStatsTable;
  Map<String, dynamic>? cachedBaseSkillTable;
  Map<String, dynamic>? cachedTeamTable;
  Map<String, dynamic>? cachedCharPatch;
  Map<String, dynamic>? cachedCharMeta;
  Map<String, dynamic>? cachedGamedataConst;
  bool cached = false;
  bool isCached = false;

  void setIsCached({
    required Servers server,
    required String version,
    required bool cached,
  }) {
    final result =
        cached && cachedListOperatorServer == server && cachedListOperatorVersion == version;
    if (result == isCached) return;
    isCached = result;
    notifyListeners();
  }

  void cache({
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
  }) {
    cachedListOperator = listOperator;
    cachedListOperatorServer = listOperatorServer;
    cachedListOperatorVersion = listOperatorVersion;
    cachedRangeTable = rangeTable;
    cachedSkillTable = skillTable;
    cachedModTable = modTable;
    cachedBaseSkillTable = baseSkillTable;
    cachedModStatsTable = modStatsTable;
    cachedTeamTable = teamTable;
    cachedCharPatch = charPatch;
    cachedCharMeta = charMeta;
    cachedGamedataConst = gamedataConst;

    cached = true;
    notifyListeners();
  }

  void unCache() {
    cachedListOperator = null;
    cachedListOperatorServer = null;
    cachedListOperatorVersion = null;
    cachedRangeTable = null;
    cachedSkillTable = null;
    cachedModTable = null;
    cachedBaseSkillTable = null;
    cachedModStatsTable = null;
    cachedTeamTable = null;
    cachedCharPatch = null;
    cachedCharMeta = null;
    cachedGamedataConst = null;
    if (NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().opFetched == true) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setOpFetched(false);
    }

    cached = false;
    notifyListeners();
  }
}
