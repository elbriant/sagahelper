import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/components/stat_tile.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/op_info_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

/// [operator, modules info table]
List<Map<String, dynamic>> calculateModulesInfo(List input) {
  return List.generate(input[0].modules!.length, (index) {
    return input[1]["equipDict"][input[0].modules![index]];
  });
}

/// [module info list, modules stat table]
List<Map?> calculateModulesStats(List input) {
  return List.generate(input[0].length, (index) {
    final Map mod = input[0][index];
    final isAdvanced = (mod["type"] as String).toLowerCase() == 'advanced';

    if (isAdvanced) {
      return input[1][mod["uniEquipId"]];
    }

    return null;
  });
}

List<List<int>> calculateStagesList(List<Map?> modulesStats) {
  List<List<int>> result = List.generate(
    modulesStats.length,
    (index) {
      List<int> modStages =
          List.generate((modulesStats[index]?['phases'] as List?)?.length ?? 0, (n) => n);
      modStages.sort();
      return modStages;
    },
  );

  return result;
}

List<List<int>> calculatePotsList(List<Map?> modulesStats) {
  List<List<int>> result = List.generate(
    modulesStats.length,
    (index) {
      List<int> modPots = [];

      if (modulesStats[index]?['phases'] != null) {
        for (Map phases in modulesStats[index]?['phases']) {
          for (Map part in phases["parts"]) {
            if (part["addOrOverrideTalentDataBundle"]["candidates"] == null) continue;
            for (Map candidate in part["addOrOverrideTalentDataBundle"]["candidates"]) {
              int thisCandidatePot = candidate["requiredPotentialRank"];
              if (!modPots.contains(thisCandidatePot)) {
                modPots.add(thisCandidatePot);
              }
            }
          }
        }
      }

      modPots.sort();
      return modPots;
    },
  );
  return result;
}

class OperatorModules extends StatefulWidget {
  const OperatorModules({
    super.key,
    required this.operator,
  });

  final Operator operator;

  @override
  State<OperatorModules> createState() => _OperatorModulesState();
}

class _OperatorModulesState extends State<OperatorModules> {
  int currentModule = 0;
  int currentStage = 0;
  int? localPotential;
  bool dataLoaded = false;

  late List<Map<String, dynamic>> modulesInfoList;
  late List<Map?> moduleStatList;
  late List<List<int>> modStagesList;
  late List<List<int>> modPotsList;

  void getModuleData() async {
    final modulesStatTable = context.read<CacheProvider>().cachedModStatsTable!;
    final moduleInfoTable = context.read<CacheProvider>().cachedModInfoTable!;

    modulesInfoList = await compute(calculateModulesInfo, [widget.operator, moduleInfoTable]);
    moduleStatList = await compute(calculateModulesStats, [modulesInfoList, modulesStatTable]);
    modStagesList = await compute(calculateStagesList, moduleStatList);
    modPotsList = await compute(calculatePotsList, moduleStatList);

    if (mounted) {
      setState(() {
        dataLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getModuleData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (localPotential != context.read<OpInfoProvider>().potential && localPotential != null) {
      localPotential = null;
    }
  }

  void calculateChanges() {
    Map<String, double> result = {};
    final Map? selectedModStats = moduleStatList[currentModule];

    if (selectedModStats?["phases"][currentStage]["attributeBlackboard"] == null) {
      context.read<OpInfoProvider>().setModAttrBuffs(result);
      return;
    }

    for (var attribute
        in (selectedModStats?["phases"][currentStage]["attributeBlackboard"] as List)) {
      String name = switch (attribute['key']) {
        "respawn_time" => "respawnTime",
        "attack_speed" => "attackSpeed",
        "max_hp" => "maxHp",
        "magic_resistance" => "magicResistance",
        _ => attribute['key'],
      };
      result.update(
        name,
        (value) => value + attribute['value'],
        ifAbsent: () => attribute['value'],
      );
    }
    context.read<OpInfoProvider>().setModAttrBuffs(result);
  }

  String joinModName(Map mod) {
    return <String?>[mod["typeName1"], mod["typeName2"]].nonNulls.join('-');
  }

  /// module has to be advanced for this, so moduleStats will be non-null
  List<Widget> statsUpgrades() {
    var result = <Widget>[];

    for (var attribute in (moduleStatList[currentModule]!["phases"][currentStage]
        ["attributeBlackboard"] as List)) {
      result.add(
        StatTile(
          stat: Operator.statTranslate(attribute['key']),
          value: (attribute['value'] as double).toStringWithPrecision(),
          isBonus: true,
        ),
      );
    }

    return result;
  }

  /// module has to be advanced for this, so moduleStats will be non-null
  List<Widget> allOtherUpgrades(int minPot) {
    var result = <Widget>[];
    String changedText = '';
    String title = '';
    String subtitle = '';
    bool isAdding = false;
    final Map selectedPhase = moduleStatList[currentModule]!["phases"][currentStage];

    for (Map part in selectedPhase["parts"]) {
      if (part["isToken"] == true) continue; // should change this

      // i dont really understand ak's backend so im gonna just do my best
      switch ((part["target"] as String)) {
        case 'DISPLAY':
        // often just adds or overrides trait text
        case 'TRAIT':
        // same as display but also contains "resKey" value
        // dunno wtf does "resKey" tho
        case 'TRAIT_DATA_ONLY':
          // same as display but often just overrides
          if (part["overrideTraitDataBundle"]["candidates"] == null) continue;
          Map candidate =
              (part["overrideTraitDataBundle"]["candidates"] as List).lastWhere((candidate) {
            int thisTalentCandidatePot = candidate["requiredPotentialRank"];
            return (localPotential ?? minPot) >= thisTalentCandidatePot;
          });
          changedText = ((candidate["overrideDescripton"] ?? widget.operator.description ?? '') +
                  (candidate["additionalDescription"] != null
                      ? '\n<add-icon/><diffInsert>${candidate["additionalDescription"]}</diffInsert>'
                      : '') as String)
              .varParser(candidate["blackboard"]);
          title = widget.operator.subProfessionString;
          subtitle = 'Trait';
          isAdding = candidate["additionalDescription"] != null;
          continue createWidget;

        case 'TALENT':
        // displays talent changes if attribute ["talentIndex"] is >= 0
        // i dont know exactly what affects ["talentIndex"] == -1
        case 'TALENT_DATA_ONLY':
          // sames as talent
          if (part["addOrOverrideTalentDataBundle"]["candidates"] == null) continue;

          Map candidate =
              (part["addOrOverrideTalentDataBundle"]["candidates"] as List).lastWhere((candidate) {
            int thisTalentCandidatePot = candidate["requiredPotentialRank"];
            return (localPotential ?? minPot) >= thisTalentCandidatePot;
          });

          //range expands
          if (candidate["displayRangeId"] && candidate["rangeId"] != null) {
            result.add(
              RangeTile.smol(candidate["rangeId"]),
            );
          }

          if (candidate["talentIndex"] < 0) continue;
          if (candidate["isHideTalent"]) continue;

          final int thisCandidateTalentIndex = candidate["talentIndex"];
          changedText =
              ((candidate["description"] ?? candidate["upgradeDescription"] ?? '') as String)
                  .varParser(candidate["blackboard"]);
          title = candidate["name"] ??
              (widget.operator.talents[thisCandidateTalentIndex]["candidates"] as List)
                  .first["name"] ??
              '';
          subtitle = 'Talent ${(thisCandidateTalentIndex + 1).toString()}';
          isAdding = false;
          continue createWidget;

        createWidget:
        case 'createWidget':
          var baseWidget = Card.filled(
            margin: const EdgeInsets.only(top: 12.0),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 2.0,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$title - ',
                          ),
                          TextSpan(
                            text: subtitle,
                            style: TextStyle(
                              color: isAdding
                                  ? StaticColors.fromBrightness(context).greenVariant
                                  : StaticColors.fromBrightness(context).yellowVariant,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: SizedBox(
                      width: double.maxFinite,
                      child: StyledText(
                        text: changedText.akRichTextParser(),
                        tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          result.add(baseWidget);
        case _:
          log('${part["target"]} not found');
      }
    }
    return result;
  }

  void showModStory() async {
    await showModalBottomSheet<void>(
      constraints: BoxConstraints.loose(
        Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.75,
        ),
      ),
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        final isAdvanced =
            (modulesInfoList[currentModule]["type"] as String).toLowerCase() == 'advanced';

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    modulesInfoList[currentModule]["uniEquipDesc"],
                  ),
                  const SizedBox(height: 20),
                  StoredImage(
                    imageUrl:
                        '$kModImgRepo/${isAdvanced ? modulesInfoList[currentModule]["uniEquipIcon"] : 'default'}.png',
                    filePath:
                        'modart/${isAdvanced ? modulesInfoList[currentModule]["uniEquipIcon"] : 'default'}.png',
                    placeholder: Image.asset(
                      'assets/placeholders/module.png',
                      colorBlendMode: BlendMode.modulate,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void changeSelectedMod(int index) {
    if (index == currentModule) return;
    setState(() {
      currentModule = index;

      currentStage = modStagesList[currentModule].lastOrNull ?? 0;

      if (localPotential != null) {
        localPotential = null;
      }
    });
    calculateChanges();
  }

  void setStage(int stage) {
    if (stage == currentStage) return;
    setState(() {
      currentStage = stage;
    });
    calculateChanges();
  }

  void setPotential(int pot) {
    if (localPotential == pot) return;
    setState(() {
      localPotential = pot;
    });
    // calculateChanges();
  }

  @override
  Widget build(BuildContext context) {
    final currentElite = context.select<OpInfoProvider, int>((p) => p.elite);
    final currentPotential = context.select<OpInfoProvider, int>((p) => p.potential);

    Widget child = const SizedBox.shrink();

    if (currentElite < 2) {
      child = StyledText(
        key: const Key('e2modules'),
        text: '<icon src="assets/sortIcon/lock.png"/> Module system unlocked at Elite 2',
        tags: context.read<StyleProvider>().tagsAsArknights(context: context),
      );
    } else if (!dataLoaded) {
      child = ShimmerLoadingMask(
        key: const Key('placeholder'),
        child: Container(
          margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8.0),
          ),
          width: double.maxFinite,
          height: 340,
        ),
      );
    } else {
      int minPot = modPotsList[currentModule].lastWhere(
        (e) => e <= currentPotential,
        orElse: () => modPotsList[currentModule].firstOrNull ?? 0,
      );

      final isAdvanced =
          (modulesInfoList[currentModule]["type"] as String).toLowerCase() == 'advanced';

      child = Container(
        key: const Key('modules'),
        width: double.maxFinite,
        padding: const EdgeInsets.all(24.0),
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Available modules:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(modulesInfoList.length, (index) {
                  final isThisAdvanced =
                      (modulesInfoList[index]["type"] as String).toLowerCase() == 'advanced';
                  final double dimension = 46;
                  final bool selected = currentModule == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    width: dimension,
                    height: dimension,
                    margin: const EdgeInsets.only(left: 6.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image(
                              image: isThisAdvanced
                                  ? NetworkToFileImage(
                                      url:
                                          '$kModIconRepo/${(modulesInfoList[index]["typeIcon"] as String).toLowerCase() == 'trp-d' ? 'TRP-D' : (modulesInfoList[index]["typeIcon"] as String).toLowerCase()}.png'
                                              .githubEncode(),
                                      file: LocalDataManager.localCacheFileSync(
                                        'modicon/${modulesInfoList[index]["typeIcon"]}.png',
                                      ),
                                    )
                                  : const AssetImage('assets/placeholders/original.png'),
                              colorBlendMode: BlendMode.modulate,
                              color: selected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context)
                                      .colorScheme
                                      .inverseSurface
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () => changeSelectedMod(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 75,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                isThreeLine: true,
                leading: Container(
                  width: 60,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: HSLColor.fromColor(Theme.of(context).colorScheme.primary)
                        .withLightness(0.10)
                        .toColor(),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/modules_shining/${modulesInfoList[currentModule]["equipShiningColor"].toLowerCase()}_shining.png',
                        width: 60,
                        height: 56,
                        scale: 1.4,
                      ),
                      Image(
                        image: isAdvanced
                            ? NetworkToFileImage(
                                url:
                                    '$kModIconRepo/${modulesInfoList[currentModule]["typeIcon"] == 'trp-d' ? 'TRP-D' : modulesInfoList[currentModule]["typeIcon"]}.png'
                                        .githubEncode(),
                                file: LocalDataManager.localCacheFileSync(
                                  'modicon/${modulesInfoList[currentModule]["typeIcon"]}.png',
                                ),
                              )
                            : const AssetImage('assets/placeholders/original.png'),
                        filterQuality: FilterQuality.high,
                        width: 60 / 1.4,
                        height: 56 / 1.4,
                      ),
                    ],
                  ),
                ),
                title: Text(
                  modulesInfoList[currentModule]["uniEquipName"],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
                subtitle: Text(
                  joinModName(modulesInfoList[currentModule]),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ),
            if (isAdvanced)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(modStagesList[currentModule].length, (index) {
                          return LilButton(
                            selected: modStagesList[currentModule][index] == currentStage,
                            fun: () => setStage(index),
                            icon: Text.rich(
                              textScaler: const TextScaler.linear(0.8),
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Stage', style: TextStyle(fontSize: 10)),
                                  TextSpan(
                                    text: (modStagesList[currentModule][index] + 1).toString(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      Row(
                        children: List.generate(modPotsList[currentModule].length, (index) {
                          return LilButton(
                            selected:
                                modPotsList[currentModule][index] == (localPotential ?? minPot),
                            fun: () => setPotential(modPotsList[currentModule][index]),
                            icon: Image.asset(
                              'assets/pot/potential_${modPotsList[currentModule][index]}_small.png',
                              scale: modPotsList[currentModule].length < 4 ? 1 : 1.5,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bonus stats:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    alignment: WrapAlignment.start,
                    children: statsUpgrades(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aditional upgrades:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  Column(
                    children: allOtherUpgrades(minPot),
                  ),
                ],
              ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.hardEdge,
              width: double.maxFinite,
              height: 80,
              child: Stack(
                children: [
                  StoredImage(
                    imageUrl:
                        '$kModImgRepo/${isAdvanced ? modulesInfoList[currentModule]["uniEquipIcon"] : 'default'}.png',
                    filePath:
                        'modart/${isAdvanced ? modulesInfoList[currentModule]["uniEquipIcon"] : 'default'}.png',
                    fit: BoxFit.none,
                    width: double.maxFinite,
                    alignment: const Alignment(-0.8, 0),
                    scale: 3.0,
                    colorBlendMode: BlendMode.modulate,
                    color: const Color.fromARGB(129, 255, 255, 255),
                    placeholder: Image.asset(
                      'assets/placeholders/module.png',
                      colorBlendMode: BlendMode.modulate,
                      color: Colors.transparent,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.read_more,
                              color: Theme.of(context).colorScheme.primary,
                              shadows: [const Shadow(blurRadius: 3.0)],
                              size: 24,
                            ),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          const TextSpan(text: ' Story'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        shadows: [const Shadow(blurRadius: 3.0)],
                      ),
                      textScaler: const TextScaler.linear(1.2),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: showModStory,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: child,
    );
  }
}
