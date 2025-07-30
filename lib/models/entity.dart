// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:provider/provider.dart';

import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/errors.dart';
import 'package:sagahelper/providers/cache_provider.dart';

class Entity {
  final String id;
  final String name;
  final String description;
  final String position;

  /// probably always 'TOKEN'
  final String profession;

  /// Probably always 'notchar1'
  final String subprofession;

  /// operator values, if null will deafult to use max values instead
  final int? level;

  /// operator values, if null will deafult to use max values instead
  final int? elite;

  /// operator values, if null will deafult to use max values instead
  final int? potential;

  /// operator values, if null will deafult to use max values instead
  final int? selectedSkill;

  /// operator values, if null will deafult to use max values instead
  final int? selectedSkillLv;

  final String rangeId;

  final List<dynamic> phases;
  final List<dynamic>? skills;
  final List<dynamic>? talents;

  Entity({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.profession,
    required this.subprofession,
    required this.level,
    required this.elite,
    required this.potential,
    required this.selectedSkill,
    required this.selectedSkillLv,
    required this.rangeId,
    required this.phases,
    this.skills,
    this.talents,
  });

  factory Entity.fromId({
    required String id,
    int? lv,
    int? elite,
    int? pot,
    int? selectedSkill,
    int? skillLevel,
  }) {
    if (!NavigationService.navigatorKey.currentContext!.read<CacheProvider>().operatorsDataCached) {
      throw NoCacheException(error: 'no cache trying to create an entity from id');
    }
    final cacheCharTable =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedCharTable!;
    final Map entity = cacheCharTable[id];

    return Entity(
      name: entity["name"],
      description: entity["description"] ?? '<i-sub> no description </i-sub>',
      position: entity["position"],
      profession: entity["profession"],
      subprofession: entity["subProfessionId"],
      phases: entity["phases"],
      id: id,
      elite: elite,
      level: lv,
      potential: pot,
      skills: (entity["skills"] as List?)?.isEmpty ?? true ? null : entity["skills"],
      talents: (entity["talents"] as List?)?.isEmpty ?? true ? null : entity["talents"],
      rangeId: entity["phases"][elite ?? (entity["phases"] as List).length - 1]["rangeId"],
      selectedSkill: selectedSkill,
      selectedSkillLv: skillLevel,
    );
  }
}
