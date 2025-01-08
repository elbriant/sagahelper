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

  bool get isCached {
    Servers server =
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;
    String version =
        NavigationService.navigatorKey.currentContext!.read<ServerProvider>().versionOf(server);

    if (cachedListOperator != null &&
        cachedListOperatorServer == server &&
        cachedListOperatorVersion == version &&
        cachedRangeTable != null &&
        cachedSkillTable != null &&
        cachedModTable != null &&
        cachedBaseSkillTable != null &&
        cachedModStatsTable != null) {
      return true;
    } else {
      return false;
    }
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
  }) {
    cachedListOperator = listOperator;
    cachedListOperatorServer = listOperatorServer;
    cachedListOperatorVersion = listOperatorVersion;
    cachedRangeTable = rangeTable;
    cachedSkillTable = skillTable;
    cachedModTable = modTable;
    cachedBaseSkillTable = baseSkillTable;
    cachedModStatsTable = modStatsTable;
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
    if (NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().opFetched == true) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setOpFetched(false);
    }
  }
}
