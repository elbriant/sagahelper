import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/recruit_combo.dart';
import 'package:sagahelper/models/recruit_operator.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_pool_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_selected_tags_provider.dart';

/// Generates all subsets of [set] with length 1 to [maxLength].
List<List<int>> _getCombinations(List<int> set, {int maxLength = 3}) {
  final elements = set;
  final combinations = <List<int>>[[]];

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

final recruitResultsProvider = FutureProvider.autoDispose<List<RecruitCombo>>((ref) async {
  final poolData = await ref.watch(recruitPoolProvider.future);
  final selectedTags = ref.watch(recruitSelectedTagsProvider);

  if (selectedTags.isEmpty) return const [];

  return _computeResults(poolData, selectedTags.selectedTagIds.toList());
});

List<RecruitCombo> _computeResults(List<RecruitOperator> pool, List<int> selectedTagIds) {
  final groups = <RecruitCombo>[];

  final combinations = _getCombinations(selectedTagIds);

  for (final combo in combinations) {
    final matches = <RecruitOperator>[];
    final hasTopOp = combo.contains(11);

    for (final op in pool) {
      if (!hasTopOp && op.op.rarity >= 6) continue;
      if (combo.every((tagId) => op.allTagIds.contains(tagId))) {
        matches.add(op);
      }
    }

    if (matches.isEmpty) continue;

    // lowestRarity: minimum rarity among operators with rarity >= 2 (exclude 1★)
    int lowestRarity = 99;
    for (final op in matches) {
      if (op.op.rarity >= 2 && op.op.rarity < lowestRarity) {
        lowestRarity = op.op.rarity;
      }
    }
    if (lowestRarity == 99) lowestRarity = 1;

    // highestRarity: maximum rarity among all matches
    int highestRarity = 0;
    for (final op in matches) {
      if (op.op.rarity > highestRarity) {
        highestRarity = op.op.rarity;
      }
    }

    // nineHourOpCount: count of 3★+ operators
    int nineHourOpCount = 0;
    for (final op in matches) {
      if (op.op.rarity >= 3) nineHourOpCount++;
    }

    // Sort matches: rarity ascending, then name alphabetically
    matches.sort((a, b) {
      if (a.op.rarity != b.op.rarity) return a.op.rarity.compareTo(b.op.rarity);
      return a.op.name.compareTo(b.op.name);
    });

    groups.add(RecruitCombo(
      tagIds: combo,
      matches: matches,
      lowestRarity: lowestRarity,
      highestRarity: highestRarity,
      matchCount: nineHourOpCount,
    ),);
  }

  // Sort groups: most tags first, then highestRarity desc, then lowestRarity desc
  groups.sort((a, b) {
    if (b.tagIds.length != a.tagIds.length) return b.tagIds.length - a.tagIds.length;
    if (b.highestRarity != a.highestRarity) return b.highestRarity - a.highestRarity;
    return b.lowestRarity - a.lowestRarity;
  });

  return groups;
}
