import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/recruit_operator.dart';
import 'package:sagahelper/providers/operator_list_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';

const _positionToTagId = <String, int>{
  'melee': 9,
  'ranged': 10,
};

const _professionToTagId = <String, int>{
  'warrior': 1, // Guard
  'sniper': 2,
  'tank': 3, // Defender
  'medic': 4,
  'support': 5, // Supporter
  'caster': 6,
  'special': 7, // Specialist
  'pioneer': 8, // Vanguard
};

/// rarity (Dart 1-6) → tagId
const _rarityToTagId = <int, int>{
  1: 28, // 1★
  2: 17, // 2★
  5: 14, // 5★
  6: 11, // 6★ Top Operator
};

const _opNameSubstitutions = <String, String>{
  "justice knight": "'justice knight'",
  "サーマル-ex": "thrm-ex",
  "샤미르": "샤마르",
};

final recruitPoolProvider = FutureProvider.autoDispose<List<RecruitOperator>>((ref) async {
  final gachaTableString = await ref
      .watch(currentServerNotifierProvider.select((p) => p.tryGetFile(GameFile.gacha.path)));
  if (gachaTableString == null) throw Exception('Update Gamedata');
  final operatorList = await ref.watch(operatorListProvider.future);
  final gachaJson = jsonDecode(gachaTableString);

  final gachaTagsRaw = gachaJson['gachaTags'] as List;

  // Build tagId → tagName map
  final tagMap = <int, String>{};
  for (final t in gachaTagsRaw) {
    final tagId = t['tagId'] as int;
    final tagName = t['tagName'] as String;
    tagMap[tagId] = tagName;
  }

  // Build lowercase tagName → tagId for matching operator tagList (excluding hidden tags)
  const hiddenTagIds = {1012, 1013};
  final lowerTagNameToTagId = <String, int>{};
  for (final t in gachaTagsRaw) {
    final tagId = t['tagId'] as int;
    if (hiddenTagIds.contains(tagId)) continue;
    final tagName = t['tagName'] as String;
    lowerTagNameToTagId[tagName.toLowerCase()] = tagId;
  }

  // inverse map (name → key)
  final nameMap = <String, String>{};
  for (var op in operatorList) {
    nameMap[op.name.toLowerCase()] = op.id;
  }

  List<String> validKeys = [];
  Set<String> uniqueKeys = {};

  // Parse recruitDetail to get valid operator names
  final regex = RegExp(
    r'(?<!>\s)<@rc\.eml>([^,，]*?)<\/>|(?:\/\s*|\n\s*|\\n\s*)((?!-)[^\r\/>★]+?(?<!-))(?=\/|$)',
    caseSensitive: false,
    multiLine: true,
  );

  final matches = regex.allMatches(gachaJson['recruitDetail']);

  for (final match in matches) {
    // group(1) = green-marked (unique), group(2) = normal
    final bool isUnique = match.group(1) != null;
    String? opName = match.group(1) ?? match.group(2);
    if (opName != null) {
      opName = opName.trim().toLowerCase();
      if (_opNameSubstitutions.containsKey(opName)) {
        opName = _opNameSubstitutions[opName]!;
      }
      if (nameMap.containsKey(opName)) {
        validKeys.add(nameMap[opName]!);
        if (isUnique) uniqueKeys.add(nameMap[opName]!);
      } else {
        throw Exception("not found: '$opName'");
      }
    }
  }

  final validOperators = operatorList.where((e) => validKeys.contains(e.id)).toList();

  // Build RecruitOperator for each operator with full tag info
  final result = <RecruitOperator>[];
  for (final op in validOperators) {
    final tagIds = <int>{};

    // 1. Add tags from operator's tagList (affixes like DPS, Defense, etc.)
    for (final tagName in op.tagList) {
      final tagId = lowerTagNameToTagId[(tagName as String).toLowerCase()];
      if (tagId != null) tagIds.add(tagId);
    }

    // 2. Add position tag
    final posTagId = _positionToTagId[op.position.toLowerCase()];
    if (posTagId != null) tagIds.add(posTagId);

    // 3. Add profession/class tag
    final classTagId = _professionToTagId[op.profession.toLowerCase()];
    if (classTagId != null) tagIds.add(classTagId);

    // 4. Compute tagNamesNoRarity (all tags except rarity)
    final rarityTagIds = _rarityToTagId.values.toSet();
    final tagNamesNoRarity =
        tagIds.where((id) => !rarityTagIds.contains(id)).map((id) => tagMap[id]!).toList()..sort();

    // 5. Add rarity tag
    final rarityTagId = _rarityToTagId[op.rarity];
    if (rarityTagId != null) tagIds.add(rarityTagId);

    // 6. Compute all tag names (sorted)
    final allTagNames = tagIds.map((id) => tagMap[id]!).toList()..sort();

    result.add(
      RecruitOperator(
        op: op,
        unique: uniqueKeys.contains(op.id),
        allTagIds: tagIds.toList(),
        allTagNames: allTagNames,
        tagNamesNoRarity: tagNamesNoRarity,
      ),
    );
  }

  result.sort((a, b) => b.op.rarity.compareTo(a.op.rarity));
  return result;
});
