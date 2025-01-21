import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/stat_tile.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

typedef ModChangedCallback<T> = void Function(T value, Map<String, double> attributesMap);

class OperatorModules extends StatelessWidget {
  const OperatorModules({
    super.key,
    required this.operator,
    required this.currentElite,
    required this.currentPot,
    required this.currentModuleSelected,
    this.currentModStage,
    this.localModPotential,
    required this.modAttributesBuffs,
    required this.currentTrait,
    required this.onModChanged,
    required this.onModStageChanged,
    required this.onLocalModPotentialChanged,
  });

  final Operator operator;
  final int currentElite;
  final int currentPot;
  final int currentModuleSelected;
  final int? currentModStage;
  final int? localModPotential;
  final Map<String, double> modAttributesBuffs;
  final String currentTrait;

  final ModChangedCallback<int> onModChanged;
  final ModChangedCallback<int> onModStageChanged;
  final ModChangedCallback<int> onLocalModPotentialChanged;

  @override
  Widget build(BuildContext context) {
    if (currentElite < 2) {
      return StyledText(
        text: '<icon src="assets/sortIcon/lock.png"/> Module system unlocked at Elite 2',
        tags: context.read<StyleProvider>().tagsAsArknights(context: context),
        async: true,
      );
    }

    // null check cuz at this point of runtime, data should be cached
    final cachedTable =
        context.select<CacheProvider, Map<String, dynamic>>((p) => p.cachedModTable!);
    final cachedstatsTable =
        context.select<CacheProvider, Map<String, dynamic>>((p) => p.cachedModStatsTable!);

    final List<Map<String, dynamic>> modules = List.generate(operator.modules!.length, (index) {
      return cachedTable["equipDict"][operator.modules![index]];
    });

    final Map selectedMod = modules[currentModuleSelected];
    final isAdvanced = (selectedMod["type"] as String).toLowerCase() == 'advanced';
    final Map? selectedModStats = cachedstatsTable[selectedMod["uniEquipId"]];

    List<int> modStages =
        List.generate((selectedModStats?['phases'] as List?)?.length ?? 0, (n) => n);
    List<int> modPots = [];

    if (selectedModStats?['phases'] != null) {
      for (Map phases in selectedModStats?['phases']) {
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
    modStages.sort();
    modPots.sort();

    int minStage = modStages.firstOrNull ?? 0;
    int minPot = modPots.lastWhere((e) => e <= currentPot, orElse: () => modPots.firstOrNull ?? 0);

    int? overrideLocalPot;

    if (localModPotential != null && !modPots.contains(localModPotential)) {
      overrideLocalPot = modPots.lastWhere(
        (e) => e <= localModPotential!,
        orElse: () => modPots.firstOrNull ?? 0,
      );
    }

    Map<String, double> calculateChanges() {
      Map<String, double> result = {};
      final Map? selectedModStats = cachedstatsTable[modules[currentModuleSelected]["uniEquipId"]];

      if (selectedModStats?["phases"][currentModStage ?? minStage]["attributeBlackboard"] == null) {
        return result;
      }

      for (var attribute in (selectedModStats?["phases"][currentModStage ?? minStage]
          ["attributeBlackboard"] as List)) {
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
      return result;
    }

    String joinModName(Map mod) {
      return <String?>[mod["typeName1"], mod["typeName2"]].nonNulls.join('-');
    }

    Widget modIcon(Map mod) {
      final isAdvanced = (mod["type"] as String).toLowerCase() == 'advanced';
      final double scale = 1.4;

      return Container(
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
              'assets/modules_shining/${mod["equipShiningColor"].toLowerCase()}_shining.png',
              width: 60,
              height: 56,
              scale: scale,
            ),
            Image(
              image: isAdvanced
                  ? NetworkToFileImage(
                      url:
                          '$kModIconRepo/${mod["typeIcon"] == 'trp-d' ? 'TRP-D' : mod["typeIcon"]}.png'
                              .githubEncode(),
                      file: LocalDataManager.localCacheFileSync('modicon/${mod["typeIcon"]}.png'),
                    )
                  : const AssetImage('assets/placeholders/original.png'),
              filterQuality: FilterQuality.high,
              width: 60 / scale,
              height: 56 / scale,
            ),
          ],
        ),
      );
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
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedMod["uniEquipDesc"],
                    ),
                    const SizedBox(height: 20),
                    StoredImage(
                      imageUrl:
                          '$kModImgRepo/${isAdvanced ? selectedMod["uniEquipIcon"] : 'default'}.png',
                      filePath:
                          'modart/${isAdvanced ? selectedMod["uniEquipIcon"] : 'default'}.png',
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

    List<Widget> getModulesList() {
      return List.generate(modules.length, (index) {
        final isAdvanced = (modules[index]["type"] as String).toLowerCase() == 'advanced';
        final double dimension = 46;
        final bool selected = currentModuleSelected == index;

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
                    image: isAdvanced
                        ? NetworkToFileImage(
                            url:
                                '$kModIconRepo/${modules[index]["typeIcon"] == 'trp-d' ? 'TRP-D' : modules[index]["typeIcon"]}.png'
                                    .githubEncode(),
                            file: LocalDataManager.localCacheFileSync(
                              'modicon/${modules[index]["typeIcon"]}.png',
                            ),
                          )
                        : const AssetImage('assets/placeholders/original.png'),
                    colorBlendMode: BlendMode.modulate,
                    color: selected
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => onModChanged.call(index, calculateChanges()),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }

    List<Widget> statsUpgrades() {
      var result = <Widget>[];

      for (var attribute in (selectedModStats?["phases"][currentModStage ?? minStage]
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

    List<Widget> allOtherUpgrades() {
      var result = <Widget>[];
      String changedText = '';
      String title = '';
      String subtitle = '';
      bool isAdding = false;
      final Map selectedPhase = selectedModStats!["phases"][currentModStage ?? minStage];

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
              return (overrideLocalPot ?? localModPotential ?? minPot) >= thisTalentCandidatePot;
            });
            changedText = ((candidate["overrideDescripton"] ?? currentTrait) +
                    (candidate["additionalDescription"] != null
                        ? '\n<add-icon/><diffInsert>${candidate["additionalDescription"]}</diffInsert>'
                        : '') as String)
                .varParser(candidate["blackboard"]);
            title = operator.subProfessionString;
            subtitle = 'Trait';
            isAdding = candidate["additionalDescription"] != null;
            continue createWidget;

          case 'TALENT':
          // displays talent changes if attribute ["talentIndex"] is >= 0
          // i dont know exactly what affects ["talentIndex"] == -1
          case 'TALENT_DATA_ONLY':
            // sames as talent
            if (part["addOrOverrideTalentDataBundle"]["candidates"] == null) continue;

            Map candidate = (part["addOrOverrideTalentDataBundle"]["candidates"] as List)
                .lastWhere((candidate) {
              int thisTalentCandidatePot = candidate["requiredPotentialRank"];
              return (overrideLocalPot ?? localModPotential ?? minPot) >= thisTalentCandidatePot;
            });
            if (candidate["talentIndex"] < 0) continue;
            if (candidate["isHideTalent"]) continue;

            final int thisCandidateTalentIndex = candidate["talentIndex"];
            changedText =
                ((candidate["description"] ?? candidate["upgradeDescription"] ?? '') as String)
                    .varParser(candidate["blackboard"]);
            title = candidate["name"] ??
                (operator.talents[thisCandidateTalentIndex]["candidates"] as List).first["name"] ??
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
                      curve: Curves.ease,
                      child: SizedBox(
                        width: double.maxFinite,
                        child: StyledText(
                          text: changedText,
                          tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                          textAlign: TextAlign.start,
                          async: true,
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

    return Column(
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
            children: getModulesList(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 75,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            isThreeLine: true,
            leading: modIcon(modules[currentModuleSelected]),
            title: Text(
              selectedMod["uniEquipName"],
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
            subtitle: Text(
              joinModName(modules[currentModuleSelected]),
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ),
        isAdvanced
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(modStages.length, (index) {
                          return LilButton(
                            selected: modStages[index] == (currentModStage ?? minStage),
                            fun: () => onModStageChanged.call(modStages[index], calculateChanges()),
                            icon: Text.rich(
                              textScaler: const TextScaler.linear(0.8),
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'Stage', style: TextStyle(fontSize: 10)),
                                  TextSpan(text: (modStages[index] + 1).toString()),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      Row(
                        children: List.generate(modPots.length, (index) {
                          return LilButton(
                            selected:
                                modPots[index] == (overrideLocalPot ?? localModPotential ?? minPot),
                            fun: () =>
                                onLocalModPotentialChanged.call(modPots[index], calculateChanges()),
                            icon: Image.asset(
                              'assets/pot/potential_${modPots[index]}_small.png',
                              scale: modPots.length < 4 ? 1 : 1.5,
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
                    children: allOtherUpgrades(),
                  ),
                ],
              )
            : null,
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
                    '$kModImgRepo/${isAdvanced ? selectedMod["uniEquipIcon"] : 'default'}.png',
                filePath: 'modart/${isAdvanced ? selectedMod["uniEquipIcon"] : 'default'}.png',
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
      ].nullParser(),
    );
  }
}
