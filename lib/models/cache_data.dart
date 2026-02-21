import 'package:flutter/material.dart';

import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/models/server_state.dart';

@immutable
class CacheData {
  final List<Operator>? cachedListOperator;
  final ServerState? cachedServer;
  final Map<String, dynamic>? cachedRangeTable;
  final Map<String, dynamic>? cachedSkillTable;
  final Map<String, dynamic>? cachedModInfoTable;
  final Map<String, dynamic>? cachedModStatsTable;
  final Map<String, dynamic>? cachedBaseSkillTable;
  final Map<String, dynamic>? cachedTeamTable;
  final Map<String, dynamic>? cachedCharPatch;
  final Map<String, dynamic>? cachedCharMeta;
  final Map<String, dynamic>? cachedGamedataConst;
  final Map<String, dynamic>? cachedCharTable;
  final Map<String, dynamic>? cachedGachaTable;
  final Map<String, dynamic>? cachedStageTable;

  /// just to know if variables related to operators route are cached
  /// if you want to know if is cached last version/current server
  /// consider doing it with the other providers too
  bool get operatorDataCached => (cachedListOperator != null &&
      cachedServer != null &&
      cachedRangeTable != null &&
      cachedSkillTable != null &&
      cachedModInfoTable != null &&
      cachedBaseSkillTable != null &&
      cachedModStatsTable != null &&
      cachedTeamTable != null &&
      cachedCharPatch != null &&
      cachedCharMeta != null &&
      cachedGamedataConst != null &&
      cachedCharTable != null &&
      cachedGachaTable != null);

  const CacheData({
    this.cachedListOperator,
    this.cachedServer,
    this.cachedRangeTable,
    this.cachedSkillTable,
    this.cachedModInfoTable,
    this.cachedModStatsTable,
    this.cachedBaseSkillTable,
    this.cachedTeamTable,
    this.cachedCharPatch,
    this.cachedCharMeta,
    this.cachedGamedataConst,
    this.cachedCharTable,
    this.cachedGachaTable,
    this.cachedStageTable,
  });

  CacheData copyWith({
    List<Operator>? cachedListOperator,
    ServerState? cachedServer,
    Map<String, dynamic>? cachedRangeTable,
    Map<String, dynamic>? cachedSkillTable,
    Map<String, dynamic>? cachedModInfoTable,
    Map<String, dynamic>? cachedModStatsTable,
    Map<String, dynamic>? cachedBaseSkillTable,
    Map<String, dynamic>? cachedTeamTable,
    Map<String, dynamic>? cachedCharPatch,
    Map<String, dynamic>? cachedCharMeta,
    Map<String, dynamic>? cachedGamedataConst,
    Map<String, dynamic>? cachedCharTable,
    Map<String, dynamic>? cachedGachaTable,
    Map<String, dynamic>? cachedStageTable,
  }) {
    return CacheData(
      cachedListOperator: cachedListOperator ?? this.cachedListOperator,
      cachedServer: cachedServer ?? this.cachedServer,
      cachedRangeTable: cachedRangeTable ?? this.cachedRangeTable,
      cachedSkillTable: cachedSkillTable ?? this.cachedSkillTable,
      cachedModInfoTable: cachedModInfoTable ?? this.cachedModInfoTable,
      cachedModStatsTable: cachedModStatsTable ?? this.cachedModStatsTable,
      cachedBaseSkillTable: cachedBaseSkillTable ?? this.cachedBaseSkillTable,
      cachedTeamTable: cachedTeamTable ?? this.cachedTeamTable,
      cachedCharPatch: cachedCharPatch ?? this.cachedCharPatch,
      cachedCharMeta: cachedCharMeta ?? this.cachedCharMeta,
      cachedGamedataConst: cachedGamedataConst ?? this.cachedGamedataConst,
      cachedCharTable: cachedCharTable ?? this.cachedCharTable,
      cachedGachaTable: cachedGachaTable ?? this.cachedGachaTable,
      cachedStageTable: cachedStageTable ?? this.cachedStageTable,
    );
  }
}
