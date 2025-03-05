import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/operator_container.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/stat_tile.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/entity.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:sagahelper/utils/misc.dart';
import 'package:styled_text/styled_text.dart';
import 'package:transparent_image/transparent_image.dart';

abstract final class PopupDialog {
  static const bool _useSafeArea = true;
  static const bool _barrierDismissible = true;

  static _show({
    required BuildContext context,
    bool useSafeArea = _useSafeArea,
    bool barrierDismissible = _barrierDismissible,
    Widget? icon,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    void Function()? onEndCallback,
    void Function(Object?, StackTrace?)? onErrorCallback,
  }) async {
    showDialog<void>(
      context: context,
      useSafeArea: useSafeArea,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          icon: icon,
          title: title,
          content: content,
          actions: actions,
        );
      },
    ).then(
      (_) {
        onEndCallback?.call();
      },
      onError: (e, st) {
        onErrorCallback?.call(e, st);
      },
    );
  }

  static void normal({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    void Function()? onEndCallback,
    void Function(Object?, StackTrace?)? onErrorCallback,
  }) {
    assert(title != null || content != null);
    _show(
      context: context,
      title: title,
      content: content,
      actions: actions,
      onEndCallback: onEndCallback,
      onErrorCallback: onErrorCallback,
    );
  }

  static void dictionary({
    required BuildContext context,
    required Widget term,
    required Widget definition,
  }) {
    _show(
      context: context,
      title: term,
      content: definition,
      icon: const Icon(Icons.menu_book_rounded),
    );
  }

  static void entityView({
    required Entity entity,
    required BuildContext context,
  }) {
    _show(
      context: context,
      title: Text(
        entity.name,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Builder(
        builder: (BuildContext context) {
          final int elite = entity.elite ?? entity.phases.length - 1;
          final int level = entity.level ?? (entity.phases.last as Map)["maxLevel"];
          final int potential = entity.potential ?? 5;
          final int skill = entity.selectedSkill ?? -1;
          final int skillLv = entity.selectedSkillLv ?? -1;

          String getStat(String stat) {
            List<dynamic> datakeyframe = entity.phases[elite]['attributesKeyFrames'];
            int maxLevel = entity.phases[elite]["maxLevel"];

            if (stat == 'baseAttackTime' || stat == 'respawnTime') {
              var value = lerpDouble(
                datakeyframe[0]['data'][stat],
                datakeyframe[1]['data'][stat],
                (level - 1.0) / (maxLevel - 1),
              )!;
              if (stat == 'baseAttackTime') {
                //shown value is atk interval, here we calculate the interval with the real ASPD
                value /= lerpDouble(
                      datakeyframe[0]['data']['attackSpeed'],
                      datakeyframe[1]['data']['attackSpeed'],
                      (level - 1.0) / (maxLevel - 1),
                    )! /
                    100;
              }

              return value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0*$'), '');
            } else {
              var value = lerpDouble(
                datakeyframe[0]['data'][stat],
                datakeyframe[1]['data'][stat],
                (level - 1.0) / (maxLevel - 1),
              )!;
              return value.round().toString();
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // header
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: rarityColors[0],
                        width: 2.0,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      color: HSLColor.fromColor(rarityColors[0]).withLightness(0.10).toColor(),
                    ),
                    child: FadeInImage(
                      image: NetworkToFileImage(
                        url: '$kTokenAvatarRepo/${entity.id}.png'.githubEncode(),
                        file: LocalDataManager.localCacheFileSync(
                          'entityAvatar/${entity.id}.png',
                        ),
                      ),
                      filterQuality: FilterQuality.high,
                      placeholder: MemoryImage(kTransparentImage),
                      width: 70,
                      height: 70,
                      imageErrorBuilder: (context, error, stackTrace) => const SizedBox.square(
                        dimension: 70,
                        child: Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),

                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StyledText(
                            text: entity.description,
                            textAlign: TextAlign.start,
                            async: true,
                            tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                          ),
                          Text(
                            'Deployable on ${entity.position.toLowerCase()} tiles',
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),

                  // stats
                  StyledText(
                    text: "<i-sub>Stats changes based on operator's stats</i-sub>",
                    textAlign: TextAlign.start,
                    async: true,
                    tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                  ),
                  Table(
                    border: TableBorder.symmetric(
                      inside:
                          BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
                    ),
                    columnWidths: const {0: FlexColumnWidth(0.45), 1: FlexColumnWidth(0.55)},
                    children: [
                      TableRow(
                        children: [
                          StatTileList(stat: 'HP', value: getStat('maxHp')),
                          StatTileList(stat: 'Redeploy', value: '${getStat('respawnTime')} sec'),
                        ],
                      ),
                      TableRow(
                        children: [
                          StatTileList(stat: 'ATK', value: getStat('atk')),
                          StatTileList(stat: 'Block', value: getStat('blockCnt')),
                        ],
                      ),
                      TableRow(
                        children: [
                          StatTileList(stat: 'DEF', value: getStat('def')),
                          StatTileList(stat: 'DP Cost', value: getStat('cost')),
                        ],
                      ),
                      TableRow(
                        children: [
                          StatTileList(stat: 'RES', value: '${getStat('magicResistance')}%'),
                          StatTileList(stat: 'ASPD', value: '${getStat('baseAttackTime')} sec'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  Center(
                    child: RangeTile.smol(entity.rangeId),
                  ),

                  // talents if any
                  entity.talents != null
                      ? Builder(
                          builder: (context) {
                            List<int> talentElites = [];
                            List<int> talentPots = [];

                            for (Map talent in entity.talents!) {
                              if (talent["candidates"] == null) {
                                continue;
                              }

                              for (Map candidate in talent["candidates"]) {
                                int thisTalentCandidateElite = int.parse(
                                  (candidate["unlockCondition"]["phase"] as String)
                                      .replaceFirst('PHASE_', ''),
                                );
                                if (!talentElites.contains(thisTalentCandidateElite)) {
                                  talentElites.add(thisTalentCandidateElite);
                                }

                                int thisTalentCandidatePot = candidate["requiredPotentialRank"];
                                if (!talentPots.contains(thisTalentCandidatePot)) {
                                  talentPots.add(thisTalentCandidatePot);
                                }
                              }
                            }
                            talentElites.sort();
                            talentPots.sort();

                            int minElite = talentElites.lastWhere(
                              (e) => e <= elite,
                              orElse: () => talentElites.first,
                            );
                            int minPot = talentPots.lastWhere(
                              (e) => e <= potential,
                              orElse: () => talentPots.first,
                            );

                            List<Widget?> talentWidgets =
                                List.generate(entity.talents!.length, (index) {
                              if (entity.talents![index]["candidates"] == null) {
                                return null;
                              }

                              Map? candidate =
                                  (entity.talents![index]["candidates"] as List).lastWhere(
                                (candidate) {
                                  int thisTalentCandidateElite = int.parse(
                                    (candidate["unlockCondition"]["phase"] as String)
                                        .replaceFirst('PHASE_', ''),
                                  );
                                  int thisTalentCandidatePot = candidate["requiredPotentialRank"];
                                  return (minElite) >= thisTalentCandidateElite &&
                                      (minPot) >= thisTalentCandidatePot;
                                },
                                orElse: () => null,
                              );

                              if (candidate != null && candidate["isHideTalent"] == true) {
                                return null;
                              }

                              bool unlocked = (candidate != null);

                              final talentText =
                                  (candidate?["description"] as String?)?.akRichTextParser() ??
                                      '<i-sub> no description </i-sub>';

                              List<Widget> extraSlots = [
                                if (candidate?["rangeId"] != null &&
                                    (candidate?["blackboard"] as List).singleWhere(
                                          (e) => e?["key"] == "talent_override_rangeid_flag",
                                          orElse: () => null,
                                        )?["value"] ==
                                        1.0)
                                  Expanded(child: RangeTile.smol(candidate?["rangeId"])),
                              ].nullParser();

                              return Card.filled(
                                margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
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
                                          color: unlocked
                                              ? Theme.of(context).colorScheme.primary
                                              : null,
                                          borderRadius: BorderRadius.circular(12),
                                          border: unlocked
                                              ? Border.all(
                                                  color: Theme.of(context).colorScheme.primary,
                                                )
                                              : Border.all(
                                                  color: Theme.of(context).colorScheme.outline,
                                                ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 2.0,
                                        ),
                                        child: StyledText(
                                          text: (entity.talents![index]["candidates"] as List)
                                                  .first["name"] ??
                                              '<i-sub> no name </i-sub>',
                                          style: TextStyle(
                                            color: unlocked
                                                ? Theme.of(context).colorScheme.onPrimary
                                                : Theme.of(context).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          async: true,
                                        ),
                                      ),
                                      AnimatedSize(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.ease,
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          child: StyledText(
                                            text: unlocked
                                                ? talentText
                                                : '<icon src="assets/sortIcon/lock.png"/> Unlocks at Elite $index',
                                            tags: context
                                                .read<StyleProvider>()
                                                .tagsAsArknights(context: context),
                                            textAlign: TextAlign.start,
                                            async: true,
                                          ),
                                        ),
                                      ),
                                      AnimatedSize(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.ease,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: extraSlots,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });

                            if (talentWidgets.nullParser().isEmpty) return const SizedBox.shrink();

                            return Column(
                              children: List.generate(1 + entity.talents!.length, (index) {
                                if (index == 0) {
                                  return SizedBox(
                                    width: double.maxFinite,
                                    child: Text(
                                      'Talents',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 22,
                                      ),
                                    ),
                                  );
                                } else {
                                  return talentWidgets[index - 1];
                                }
                              }).nullParser(),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 6.0,
                  ),

                  // skills if any

                  entity.skills != null
                      ? Builder(
                          builder: (context) {
                            int currentSelectedSkill = skill == -1
                                ? entity.skills!.lastIndexWhere((e) => (e["skillId"] != null))
                                : skill;

                            if (currentSelectedSkill == -1) return const SizedBox.shrink();

                            Map selectedSkill = entity.skills![currentSelectedSkill];

                            if (selectedSkill["skillId"] == null) return const SizedBox.shrink();

                            Map skillDetail = context
                                .read<CacheProvider>()
                                .cachedSkillTable![selectedSkill["skillId"]];

                            int currentSkillLevel = skillLv == -1
                                ? (context
                                                .read<CacheProvider>()
                                                .cachedSkillTable![selectedSkill["skillId"]]
                                            ["levels"] as List)
                                        .length -
                                    1
                                : skillLv;

                            Map skillDetailLv = context
                                    .read<CacheProvider>()
                                    .cachedSkillTable![selectedSkill["skillId"]]["levels"]
                                [currentSkillLevel];

                            return Column(
                              children: [
                                SizedBox(
                                  width: double.maxFinite,
                                  child: Text(
                                    'Skill',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                StyledText(
                                  text:
                                      "<i-sub>Skill changes based on operator's current selected skill</i-sub>",
                                  textAlign: TextAlign.start,
                                  async: true,
                                  tags: context
                                      .read<StyleProvider>()
                                      .tagsAsArknights(context: context),
                                ),
                                Card.filled(
                                  margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
                                  elevation: 1.0,
                                  child: Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment: AlignmentDirectional.centerStart,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(context).colorScheme.outline,
                                                ),
                                              ),
                                              padding: const EdgeInsets.only(
                                                top: 2.0,
                                                bottom: 2.0,
                                                right: 12.0,
                                                left: 42,
                                              ),
                                              child: Text(
                                                '${skillDetailLv["name"]}',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 0,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: HSLColor.fromColor(
                                                    Theme.of(context).colorScheme.primary,
                                                  ).withLightness(0.10).toColor(),
                                                  border: Border.all(
                                                    color: Theme.of(context).colorScheme.outline,
                                                  ),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: SizedBox.square(
                                                  dimension: 40,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2.0),
                                                    child: StoredImage(
                                                      imageUrl:
                                                          '$kSkillRepo/skill_icon_${skillDetail["iconId"] ?? skillDetail["skillId"]}.png'
                                                              .githubEncode(),
                                                      filePath:
                                                          'skillicon/${skillDetail["iconId"] ?? skillDetail["skillId"]}.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        StyledText(
                                          text: ((skillDetailLv["description"] as String?) ??
                                                  '<i-sub> no description </i-sub>')
                                              .akRichTextParser()
                                              .varParser(skillDetailLv["blackboard"]),
                                          tags: context
                                              .read<StyleProvider>()
                                              .tagsAsArknights(context: context),
                                          async: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static void appUpdateAlert({
    required BuildContext context,
    required String label,
    required String body,
    required String updateUrl,
    String? newVersion,
    String? currentVersion,
  }) {
    _show(
      context: context,
      title: Text(label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (newVersion != null)
            Text(
              'New version: $newVersion',
              textScaler: const TextScaler.linear(1.1),
            ),
          if (currentVersion != null)
            Text(
              'Current: $currentVersion',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          if (currentVersion != null || newVersion != null)
            const SizedBox(
              height: 10,
            ),
          const Text(
            'Changelog:',
            textScaler: TextScaler.linear(1.2),
          ),
          const SizedBox(
            height: 6,
          ),
          StyledText(
            text: body,
            tags: context.read<StyleProvider>().tagsAsHtml(context: context),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Dismiss'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Update'),
          onPressed: () {
            openUrl(updateUrl);
          },
        ),
      ],
    );
  }
}
