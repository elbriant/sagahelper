import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/recruit_all_combo.dart';
import 'package:sagahelper/models/recruit_operator.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_pool_provider.dart';

/// Generates all subsets of [set] with length 1 to [maxLength].
List<List<String>> _getStringCombinations(List<String> set, {int maxLength = 3}) {
  final elements = set;
  final combinations = <List<String>>[[]];

  for (int i = 0; i < elements.length; i++) {
    final currentSubsetLength = combinations.length;

    for (int j = 0; j < currentSubsetLength; j++) {
      if (combinations[j].length < maxLength) {
        combinations.add([...combinations[j], elements[i]]);
      }
    }
  }

  return combinations.sublist(1);
}

bool _isSuperset(Set<String> set, Set<String> subset) {
  for (final elem in subset) {
    if (!set.contains(elem)) return false;
  }
  return true;
}

/// Pre-computes all valid tag combinations and their guaranteed operators.
/// Returns a map: rootTagId → list of combos that include that root tag.
final recruitAllCombosProvider = FutureProvider.autoDispose<Map<int, List<RecruitAllCombo>>>((ref) async {
  final pool = await ref.watch(recruitPoolProvider.future);

  if (pool.isEmpty) return const {};

  // Group operators by rarity (Dart rarity 1-6)
  final threeStars = pool.where((op) => op.op.rarity == 3).toList();
  final fourStars = pool.where((op) => op.op.rarity == 4).toList();
  final fiveStars = pool.where((op) => op.op.rarity == 5).toList();
  final threeFourStars = [...threeStars, ...fourStars];

  // result: tagName → comboKey → [rarity, [operator names]]
  final res = <String, Map<String, List<dynamic>>>{};

  void getValidCombos(List<RecruitOperator> lowRarityOps, List<RecruitOperator> highRarityOps) {
    for (final op in highRarityOps) {
      final tagCombos = _getStringCombinations(op.tagNamesNoRarity);

      // Sort by length (shortest first) to enable pruning
      tagCombos.sort((a, b) => a.length.compareTo(b.length));

      for (final subset in tagCombos) {
        // Check if any low-rarity operator has a superset of these tags
        final invalid = lowRarityOps.any((lowOp) {
          return _isSuperset(
            Set<String>.from(lowOp.tagNamesNoRarity),
            Set<String>.from(subset),
          );
        });

        if (!invalid) {
          final key = (List<String>.from(subset)..sort()).join(',');

          // Check if a smaller sub-combo already exists in the result
          final smallerCombos = _getStringCombinations(subset);
          // Remove the last element (the full set itself)
          if (smallerCombos.isNotEmpty) {
            smallerCombos.removeLast();
          }

          final alreadyHasSmaller = subset.any((tag) {
            return smallerCombos.any((smallerSet) {
              final smallerKey = (List<String>.from(smallerSet)..sort()).join(',');
              return res[tag]?[smallerKey] != null;
            });
          });

          if (!alreadyHasSmaller) {
            for (final tag in subset) {
              res.putIfAbsent(tag, () => {});
              if (res[tag]!.containsKey(key)) {
                res[tag]![key]![1].add(op.op.name);
              } else {
                res[tag]![key] = [op.op.rarity, <String>[op.op.name]];
              }
            }
          }
        }
      }
    }
  }

  // Find valid combos for 5★ with 3★/4★ as low-rarity
  getValidCombos(threeFourStars, fiveStars);
  // Find valid combos for 4★ with 3★ as low-rarity
  getValidCombos(threeStars, fourStars);

  // Convert to the final result structure
  // We need to map tag names back to tag IDs using the RecruitOperator data
  final tagNameToId = <String, int>{};
  for (final op in pool) {
    for (int i = 0; i < op.allTagNames.length; i++) {
      final tagId = op.allTagIds[i];
      final tagName = op.allTagNames[i];
      tagNameToId[tagName] = tagId;
    }
  }

  final result = <int, List<RecruitAllCombo>>{};

  for (final entry in res.entries) {
    final rootTagName = entry.key;
    final rootTagId = tagNameToId[rootTagName];
    if (rootTagId == null) continue;

    final combos = <RecruitAllCombo>[];

    for (final comboEntry in entry.value.entries) {
      final comboCsv = comboEntry.key;
      final rarity = comboEntry.value[0] as int;
      final opNames = (comboEntry.value[1] as List).cast<String>();

      final tagIds = <int>[];
      for (final tagName in comboCsv.split(',')) {
        final tagId = tagNameToId[tagName];
        if (tagId != null) tagIds.add(tagId);
      }

      // Ensure root tag is first
      tagIds.remove(rootTagId);
      tagIds.insert(0, rootTagId);

      combos.add(RecruitAllCombo(
        tagIds: tagIds,
        rarity: rarity,
        operatorNames: opNames,
      ),);
    }

    // Sort combos: by number of tags (ascending), then by rarity (descending)
    combos.sort((a, b) {
      if (a.tagIds.length != b.tagIds.length) {
        return a.tagIds.length.compareTo(b.tagIds.length);
      }
      return b.rarity.compareTo(a.rarity);
    });

    result[rootTagId] = combos;
  }

  return result;
});
