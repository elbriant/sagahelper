import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/operator_search_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';

/// compute funcs should be global
/// god helps you understanding this, my bad
List<Operator> parseOperators(List<List<String>> input) {
  var operatorsparsed = (jsonDecode(input[0][0]) as Map<String, dynamic>);
  operatorsparsed.addEntries(
    ((jsonDecode(input[1][1]) as Map<String, dynamic>)["patchChars"] as Map<String, dynamic>)
        .entries,
  );
  final loreInfo = jsonDecode(input[0][1]) as Map<String, dynamic>;
  final voiceInfo = jsonDecode(input[0][2]) as Map<String, dynamic>;
  final skinInfo = jsonDecode(input[0][3]) as Map<String, dynamic>;
  final modtable = jsonDecode(input[0][6]) as Map<String, dynamic>;
  final baseSkillInfo =
      (jsonDecode(input[0][7]) as Map<String, dynamic>)["chars"] as Map<String, dynamic>;
  final charPatch = jsonDecode(input[1][1]) as Map<String, dynamic>;

  List<Operator> opsLists = [];
  operatorsparsed.forEach((key, value) {
    if ((value['subProfessionId'] as String).startsWith('notchar') ||
        key.startsWith('trap') ||
        key.startsWith('token') ||
        value['isNotObtainable'] == true) {
    } else {
      opsLists.add(
        Operator.fromJson(
          key,
          value,
          loreInfo['handbookDict'],
          voiceInfo,
          skinInfo['charSkins'],
          baseSkillInfo,
          modtable["charEquip"],
          charPatch,
        ),
      );
    }
  });

  return opsLists;
}

// TODO: maybe add real release date sorting with
// https://github.com/ArknightsAssets/releasever/blob/master/releasever.json

final operatorListProvider = FutureProvider<List<Operator>>(
  (ref) async {
    // we do this because we dont wanna depend on all the cache, just the ones related to operator data
    final isCachedOperatorData = ref.watch(cacheProvider.select((p) => p.operatorDataCached));
    final cacheProv = ref.read(cacheProvider);
    final currentServerState = ref.watch(currentServerStateProvider);
    final currentServerNotifier = ref.read(currentServerNotifierProvider);

    if (isCachedOperatorData &&
        currentServerState.server == cacheProv.cachedServer?.server &&
        currentServerState.version == cacheProv.cachedServer?.version) {
      return Future<List<Operator>>.value(cacheProv.cachedListOperator);
    }

    final bool checkfiles = await currentServerNotifier.existFiles(kOpFiles);

    if (!checkfiles) throw const FormatException('Update gamedata');

    final List<String> fileString = [];

    for (String filepath in kOpFiles) {
      fileString.add(
        await currentServerNotifier.getFile(filepath),
      );
    }

    List<String> misc = [];

    for (String filepath in kMetadataFiles) {
      misc.add(
        await currentServerNotifier.getFile(filepath),
      );
    }

    final List<List<String>> input = [fileString, misc];

    // Use the compute function to run parsing in a separate isolate.
    List<Operator> completedList = await compute(parseOperators, input);

    // you have to use the brain here, i was lazy
    ref.read(cacheProvider.notifier).update(
          (c) => c.copyWith(
            cachedListOperator: completedList,
            cachedServer: currentServerState,
            cachedRangeTable: jsonDecode(fileString[4]) as Map<String, dynamic>,
            cachedSkillTable: jsonDecode(fileString[5]) as Map<String, dynamic>,
            cachedModInfoTable: jsonDecode(fileString[6]) as Map<String, dynamic>,
            cachedBaseSkillTable: (jsonDecode(fileString[7]) as Map<String, dynamic>)["buffs"]
                as Map<String, dynamic>,
            cachedModStatsTable: jsonDecode(fileString[8]) as Map<String, dynamic>,
            cachedTeamTable: jsonDecode(misc[0]) as Map<String, dynamic>,
            cachedCharPatch: jsonDecode(misc[1]) as Map<String, dynamic>,
            cachedCharMeta: jsonDecode(misc[2]) as Map<String, dynamic>,
            cachedGamedataConst: jsonDecode(misc[3]) as Map<String, dynamic>,
            cachedCharTable: jsonDecode(fileString[0]) as Map<String, dynamic>,
            cachedGachaTable: jsonDecode(misc[4]) as Map<String, dynamic>,
          ),
        );

    return completedList;
  },
  retry: (retryCount, error) => null,
);

final filteredOperatorListProvider = FutureProvider<List<Operator>>(
  (ref) async {
    final filteringProvider = ref.watch(operatorSearchProvider);
    final sortingType = ref.watch(configProvider.select((p) => p.operatorSortingType));
    final sortingReversed = ref.watch(configProvider.select((p) => p.useOperatorSortingReversed));
    List<Operator> list = await ref.watch(operatorListProvider.future);

    // filter first then sort

    // filtering by text
    if (filteringProvider.isSearching && filteringProvider.searchFilterString != '') {
      list = list
          .where(
            (op) => op.names.any(
              (name) =>
                  name.toLowerCase().contains(filteringProvider.searchFilterString.toLowerCase()),
            ),
          )
          .toList();
    }

    // filtering by rarity / class / subclass / etc
    if (filteringProvider.operatorFilters.isNotEmpty) {
      final whitelist = <FilterType, List<String>>{};
      final blacklist = <FilterType, List<String>>{};

      for (final filter in filteringProvider.operatorFilters.entries) {
        switch (filter.value.mode) {
          case FilterMode.whitelist:
            whitelist.update(
              filter.value.type,
              (value) {
                value.add(filter.value.key.toLowerCase());
                return value;
              },
              ifAbsent: () => [filter.value.key.toLowerCase()],
            );

          case FilterMode.blacklist:
            blacklist.update(
              filter.value.type,
              (value) {
                value.add(filter.value.key.toLowerCase());
                return value;
              },
              ifAbsent: () => [filter.value.key.toLowerCase()],
            );
        }
      }

      list = list.where((op) {
        bool test = true;

        // whitelist
        // test must evalue true
        for (var rule in whitelist.entries) {
          switch (rule.key) {
            case FilterType.rarity:
              test = rule.value.contains('r${op.rarity.toString()}');

            case FilterType.profession:
              test = rule.value.contains(op.profession.toLowerCase());

            case FilterType.subprofession:
              test = rule.value.contains(op.subProfessionId.toLowerCase());

            case FilterType.faction:
              if (op.factionIds == null) {
                test = false;
              } else {
                test = op.factionIds!.any((element) => rule.value.contains(element.toLowerCase()));
              }
            case FilterType.extra:
              List<String> values = [];
              if (op.modules != null) values.add('has_module');

              test = values.any((e) => rule.value.contains(e.toLowerCase()));
            case FilterType.position:
              test = rule.value.contains(op.position.toLowerCase());
            case FilterType.tag:
              test = op.tagList.any((element) => rule.value.contains(element.toLowerCase()));
          }
          if (test == false) break;
        }

        // blacklist
        // if test evaluate true, return false
        for (var rule in blacklist.entries) {
          switch (rule.key) {
            case FilterType.rarity:
              if (rule.value.contains('r${op.rarity.toString()}')) test = false;

            case FilterType.profession:
              if (rule.value.contains(op.profession.toLowerCase())) test = false;

            case FilterType.subprofession:
              if (rule.value.contains(op.subProfessionId.toLowerCase())) test = false;

            case FilterType.faction:
              if (op.factionIds == null) {
                test = false;
              } else {
                if (op.factionIds!.any((element) => rule.value.contains(element.toLowerCase()))) {
                  test = false;
                }
              }

            case FilterType.extra:
              List<String> values = [];
              if (op.modules != null) values.add(CustomFilterTags.hasModule.tag);

              if (values.any((e) => rule.value.contains(e.toLowerCase()))) test = false;
            case FilterType.position:
              if (rule.value.contains(op.position.toLowerCase())) test = false;
            case FilterType.tag:
              if (op.tagList.any((element) => rule.value.contains(element.toLowerCase()))) {
                test = false;
              }
          }
        }

        return test;
      }).toList();
    }

    // sorting
    switch (sortingType) {
      case OperatorSortingType.rarity:
        list.sort((a, b) {
          int cmp = b.rarity.compareTo(a.rarity);
          if (cmp != 0) return cmp;
          // subsorting is by "creation"
          return int.parse(a.id.split('_')[1]).compareTo(int.parse(b.id.split('_')[1]));
        });

      case OperatorSortingType.alphabetical:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // creation is just take the id number the op has
      case OperatorSortingType.creation:
        list.sort(
          (a, b) => int.parse(a.id.split('_')[1]).compareTo(int.parse(b.id.split('_')[1])),
        );
    }

    if (sortingReversed) list = list.reversed.toList();

    return list;
  },
  retry: (retryCount, error) => null,
);
