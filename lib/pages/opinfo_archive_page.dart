import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/big_title_text.dart';
import 'package:sagahelper/components/operator_lil_card.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/trait_card.dart';
import 'package:styled_text/styled_text.dart';
import 'package:sagahelper/components/dialog_box.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'dart:developer' as dev;

class HeaderInfo extends StatelessWidget {
  const HeaderInfo({super.key, required this.operator, required this.relatedOps});
  final Operator operator;
  final Widget relatedOps;

  @override
  Widget build(BuildContext context) {
    final professionStr = 'assets/classes/class_${operator.profession.toLowerCase()}.png';
    final subprofessionStr =
        'assets/subclasses/sub_${operator.subProfessionId.toLowerCase()}_icon.png';

    final String ghAvatarLink = '$kAvatarRepo/${operator.id}.png';
    String? logo = operator.teamId ?? operator.groupId ?? operator.nationId;
    if (logo == 'laterano' || logo == 'leithanien') {
      logo = logo!.replaceFirst('l', 'L');
    }
    final String ghLogoLink = logo == 'laios' || logo == 'rainbow'
        ? '$kLogoRepo/linkage/logo_$logo.png'
        : '$kLogoRepo/logo_$logo.png';

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          logo != null
              ? Positioned(
                  right: 1,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                          spreadRadius: 40,
                          blurRadius: 55,
                        ),
                      ],
                    ),
                    child: CachedNetworkImage(
                      colorBlendMode: BlendMode.modulate,
                      color: const Color.fromARGB(150, 255, 255, 255),
                      imageUrl: ghLogoLink,
                      scale: 2.5,
                      placeholder: (_, __) => Image.asset(
                        'assets/placeholders/logo.png',
                        colorBlendMode: BlendMode.modulate,
                        color: Colors.transparent,
                      ),
                      errorWidget: (context, url, error) => Stack(
                        children: [
                          Image.asset(
                            'assets/placeholders/logo.png',
                            colorBlendMode: BlendMode.modulate,
                            color: Colors.transparent,
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(-20, 10, -1)..rotateZ(-0.088),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    offset: Offset(0, 8.0),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 4.0,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: StoredImage(
                                colorBlendMode: BlendMode.modulate,
                                color: const Color.fromARGB(99, 255, 255, 255),
                                scale: 0.9,
                                fit: BoxFit.fitWidth,
                                placeholder: Image.asset(
                                  'assets/placeholders/avatar.png',
                                  colorBlendMode: BlendMode.modulate,
                                  color: Colors.transparent,
                                ),
                                imageUrl: ghAvatarLink,
                                filePath:
                                    'images/${operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.rotationZ(0.0),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    offset: Offset(0, 8.0),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 4.0,
                                  style: BorderStyle.solid,
                                ),
                                color: const Color.fromARGB(255, 241, 241, 241),
                              ),
                              child: StoredImage(
                                heroTag: operator.id,
                                filePath:
                                    'images/${operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                                fit: BoxFit.fitWidth,
                                placeholder: Image.asset(
                                  'assets/placeholders/avatar.png',
                                  colorBlendMode: BlendMode.modulate,
                                  color: Colors.transparent,
                                ),
                                imageUrl: ghAvatarLink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '[${operator.displayNumber} / ${operator.id}]\n',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(text: operator.itemUsage),
                      TextSpan(
                        text: '\n${operator.itemDesc}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: List.generate(operator.tagList.length + 3, (index) {
                  if (index == 0) {
                    return ActionChip(
                      label: Text(operator.professionString),
                      avatar: Image.asset(professionStr),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.85)
                          : null,
                      labelStyle: Theme.of(context).brightness == Brightness.light
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onPressed: () {},
                    );
                  }
                  if (index == 1) {
                    return ActionChip(
                      label: Text(operator.subProfessionString),
                      avatar: Image.asset(subprofessionStr),
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                          : null,
                      labelStyle: Theme.of(context).brightness == Brightness.light
                          ? const TextStyle(color: Colors.white)
                          : null,
                      onPressed: () {},
                    );
                  }
                  if (index == 2) {
                    return ActionChip(
                      label: Text(operator.position.toLowerCase().capitalize()),
                      side: BorderSide(
                        color: operator.position == 'RANGED' ? Colors.yellow[600]! : Colors.red,
                      ),
                      onPressed: () {},
                    );
                  }
                  return ActionChip(
                    label: Text(operator.tagList[index - 3]),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    onPressed: () {},
                  );
                }),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                child: relatedOps,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoreInfo extends StatelessWidget {
  const LoreInfo(this.operator, {super.key});
  final Operator operator;

  void playOperatorRecord() {
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
        .showSnackBar(const SnackBar(content: Text('not implemented yet')));
  }

  @override
  Widget build(BuildContext context) {
    bool hasOperatorRecords = (operator.loreInfo['handbookAvgList'] as List).isNotEmpty;
    List storyTextList = (operator.loreInfo['storyTextAudio'] as List);
    List operatorRecords = (operator.loreInfo['handbookAvgList'] as List);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
          hasOperatorRecords ? storyTextList.length + operatorRecords.length : storyTextList.length,
          (index) {
        if (hasOperatorRecords && index >= storyTextList.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
            child: InkWellDialogBox(
              title:
                  'Operator Record: ${operatorRecords[index - storyTextList.length]['storySetName']}',
              body: ((operatorRecords[index - storyTextList.length]['avgList'] as List).first
                  as Map)['storyIntro'],
              inkwellFun: playOperatorRecord,
            ),
          );
        }
        if (operator.opPatched &&
            !(((storyTextList[index]['stories'] as List).first as Map)["patchIdList"] as List)
                .contains(operator.id)) {
          return null;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
          child: DialogBox(
            title: storyTextList[index]['storyTitle'],
            body: ((storyTextList[index]['stories'] as List).first as Map)['storyText'],
          ),
        );
      }).nullParser(),
    );
  }
}

class SkillInfo extends StatefulWidget {
  final Operator operator;
  const SkillInfo(this.operator, {super.key});

  @override
  State<SkillInfo> createState() => _SkillInfoState();
}

class _SkillInfoState extends State<SkillInfo> {
  final CarouselSliderController carouselControllerLv = CarouselSliderController();
  final CarouselSliderController carouselControllerMod = CarouselSliderController();
  double showLevel = 1.0;
  double maxLevel = 90.0;
  int elite = 0;
  double sliderTrust = 100.0;
  bool trustMaxFlag = true;

  // trait
  late String currentTrait;

  // talents
  int? talentLocalElite;
  int? talentLocalPot;
  Map<int, String?> currentTalentsText = {};

  // base skills
  int? baseLocalElite;
  int? baseLocalLv;

  // skills
  int skillLv = 0;
  List<Map<String, dynamic>> skillsDetails = [];
  int showSkill = 0;

  // mod
  int showMod = 0;
  int? modStage;
  int? modLocalPot;
  Map<String, double> modAttrBuffs = {};

  //pot
  int pot = -1;
  Map<String, double> potBuffs = {};

  void _init() {
    //get max elite
    elite = widget.operator.phases.length - 1;
    maxLevel = (widget.operator.phases[elite]["maxLevel"] as int).toDouble();
    showLevel = maxLevel;
    sliderTrust = (widget.operator.favorKeyframes[1]["level"] as int).toDouble();
    currentTrait = getTraitText();

    // get skills
    if (widget.operator.skills.isNotEmpty) {
      for (Map skill in widget.operator.skills) {
        String skillId = skill['skillId'];
        skillsDetails.add(
          NavigationService.navigatorKey.currentContext!
              .read<CacheProvider>()
              .cachedSkillTable![skillId],
        );
      }
    }
  }

  List<dynamic>? getTraitsVars() {
    List<dynamic>? vars;

    if (widget.operator.trait != null) {
      for (int phase = elite; phase >= 0; phase--) {
        for (Map candidate in (widget.operator.trait!["candidates"] as List)) {
          if (candidate["unlockCondition"]["phase"] == 'PHASE_${phase.toString()}') {
            vars = candidate["blackboard"];
            break;
          }
        }
        if (vars != null) {
          break;
        }
      }
    }
    return vars;
  }

  String getTraitText() {
    String? trait;

    if (widget.operator.trait != null) {
      for (int phase = elite; phase >= 0; phase--) {
        for (Map candidate in (widget.operator.trait!["candidates"] as List)) {
          if (candidate["unlockCondition"]["phase"] == 'PHASE_${phase.toString()}') {
            trait = candidate["overrideDescripton"];
            break;
          }
        }
        if (trait != null) {
          break;
        }
      }
    }

    final String result =
        (trait ?? widget.operator.description ?? '').varParser(getTraitsVars()).akRichTextParser();

    return result;
  }

  String getStat(String stat) {
    List<dynamic> datakeyframe = widget.operator.phases[elite]['attributesKeyFrames'];

    if (stat == 'baseAttackTime' || stat == 'respawnTime') {
      var value = ui.lerpDouble(
        datakeyframe[0]['data'][stat],
        datakeyframe[1]['data'][stat],
        (showLevel - 1.0) / (maxLevel - 1),
      )!;
      value += getSingleTrustBonus(stat);
      if (stat == 'baseAttackTime') {
        //shown value is atk interval, here we calculate the interval with the real ASPD
        value /= ((ui.lerpDouble(
                  datakeyframe[0]['data']['attackSpeed'],
                  datakeyframe[1]['data']['attackSpeed'],
                  (showLevel - 1.0) / (maxLevel - 1),
                )! +
                (potBuffs.containsKey("attackSpeed") ? potBuffs["attackSpeed"]! : 0.0) +
                (modAttrBuffs.containsKey("attackSpeed") ? modAttrBuffs["attackSpeed"]! : 0.0)) /
            100);
      }
      if (stat == 'respawnTime' && potBuffs.containsKey('respawnTime')) {
        value += potBuffs['respawnTime']!;
      }
      if (stat == 'respawnTime' && modAttrBuffs.containsKey('respawnTime')) {
        value += modAttrBuffs['respawnTime']!;
      }
      // prettify
      return value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0*$'), '');
    } else {
      var value = ui.lerpDouble(
        datakeyframe[0]['data'][stat],
        datakeyframe[1]['data'][stat],
        (showLevel - 1.0) / (maxLevel - 1),
      )!;
      value += getSingleTrustBonus(stat);
      if (potBuffs.containsKey(stat)) value += potBuffs[stat]!;
      if (modAttrBuffs.containsKey(stat)) value += modAttrBuffs[stat]!;
      return value.round().toString();
    }
  }

  void selectElite(int i) {
    setState(() {
      talentLocalElite = null;
      if (elite == i) return;
      elite = i;
      maxLevel = (widget.operator.phases[elite]["maxLevel"] as int).toDouble();
      showLevel = showLevel.clamp(1, maxLevel);
    });
  }

  void setPot(int index) {
    setState(() {
      if (pot == index + 1) {
        pot -= 1;
      } else {
        pot = index + 1;
      }
      talentLocalPot = null;
      calcPotBonuses();
    });
  }

  double getSingleTrustBonus(String stat) {
    if (trustMaxFlag) {
      var val = widget.operator.favorKeyframes[1]["data"][stat];
      return val.runtimeType == int ? (val as int).toDouble() : val;
    } else {
      var val = ui.lerpDouble(
        widget.operator.favorKeyframes[0]["data"][stat].runtimeType == int
            ? (widget.operator.favorKeyframes[0]["data"][stat] as int).toDouble()
            : widget.operator.favorKeyframes[0]["data"][stat],
        widget.operator.favorKeyframes[1]["data"][stat].runtimeType == int
            ? (widget.operator.favorKeyframes[1]["data"][stat] as int).toDouble()
            : widget.operator.favorKeyframes[1]["data"][stat],
        sliderTrust.clamp(
              0.0,
              (widget.operator.favorKeyframes[1]["level"] as int).toDouble(),
            ) /
            (widget.operator.favorKeyframes[1]["level"] as int).toDouble(),
      )!;
      return val;
    }
  }

  List<Widget> getTrustBonus() {
    var result = <Widget>[];

    (widget.operator.favorKeyframes[1]["data"] as Map).forEach((key, value) {
      if (value.runtimeType == int || value.runtimeType == double) {
        if (value == 0) return;
        var val = value.runtimeType == int ? (value as int).toDouble() : value;

        if (!trustMaxFlag) {
          val = ui.lerpDouble(
            widget.operator.favorKeyframes[0]["data"][key],
            value,
            sliderTrust.clamp(
                  0.0,
                  (widget.operator.favorKeyframes[1]["level"] as int).toDouble(),
                ) /
                (widget.operator.favorKeyframes[1]["level"] as int).toDouble(),
          )!;
        }
        val = (val as double).round();
        if (val == 0) return;

        result.add(statTile(Operator.statTranslate(key), val.toString(), context, true));
      } else {
        if (value == false) return;
        if (!trustMaxFlag &&
            sliderTrust < (widget.operator.favorKeyframes[1]["level"] as int).toDouble()) return;

        result.add(statTile(Operator.statTranslate(key), '', context, true));
      }
    });

    return result;
  }

  void calcPotBonuses() {
    potBuffs = {};
    for (Map potDetail in widget.operator.potentials) {
      if (widget.operator.potentials.indexOf(potDetail) > pot - 1) return;

      if (potDetail["type"] == 'BUFF') {
        String name = switch ((potDetail["buff"]["attributes"]["attributeModifiers"] as List)
            .first["attributeType"]) {
          "COST" => "cost",
          "RESPAWN_TIME" => "respawnTime",
          "ATK" => "atk",
          "ATTACK_SPEED" => "attackSpeed",
          "MAX_HP" => "maxHp",
          "MAGIC_RESISTANCE" => "magicResistance",
          "DEF" => "def",
          _ => 'unknown'
        };

        if (name == 'unknown') {
          ShowSnackBar.showSnackBar(
            'Error: pot not loaded ${(potDetail["buff"]["attributes"]["attributeModifiers"] as List).first["attributeType"]}',
          );
        }

        potBuffs.update(
          name,
          (value) =>
              value +
              (potDetail["buff"]["attributes"]["attributeModifiers"] as List).first["value"],
          ifAbsent: () =>
              (potDetail["buff"]["attributes"]["attributeModifiers"] as List).first["value"],
        );
      } else {
        continue;
      }
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // maybe hold tap on elite, skill and mod to show cost material
    // do a tip show to say this ||
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          currentTrait != ''
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BigTitleText(title: 'Trait'),
                    TraitCard(
                      label: Text(
                        '${widget.operator.professionString} - ${widget.operator.subProfessionString}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      avatar: AssetImage(
                        'assets/subclasses/sub_${widget.operator.subProfessionId.toLowerCase()}_icon.png',
                      ),
                      content: StyledText(
                        text: currentTrait,
                        tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                )
              : null,
          const BigTitleText(title: 'Stats'),
          Container(
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: statsBuilder(),
          ),
          const Divider(),
          const BigTitleText(title: 'Talents'),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: talentsBuilder(),
          ),
          const Divider(),
          (widget.operator.skills.isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BigTitleText(title: 'Skills'),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(24.0),
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: skillBuilder(),
                    ),
                  ],
                )
              : null,
          (widget.operator.modules != null)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const BigTitleText(title: 'Modules'),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(24.0),
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: modulesBuilder(),
                    ),
                  ],
                )
              : null,
          (widget.operator.baseSkills.isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const BigTitleText(title: 'RIIC Base Skills'),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(24.0),
                      margin: const EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: baseSkillBuilder(),
                    ),
                  ],
                )
              : null,
        ].nullParser(),
      ),
    );
  }

  Widget statTile(String stat, String value, BuildContext context, [bool isBonus = false]) {
    return StyledText(
      text:
          '<icon-${stat.replaceAll(r' ', '')}/><color stat="${stat.replaceAll(' ', '')}">$stat</color>\n${isBonus ? '<bonusCol>+' : ''}$value${isBonus ? '</bonusCol>' : ''}',
      tags: context.read<StyleProvider>().tagsAsStats(context: context),
      style: const TextStyle(
        shadows: [ui.Shadow(offset: ui.Offset.zero, blurRadius: 1.0)],
      ),
    );
  }

  Widget smolRangeTile(String rangeId) {
    final List range = NavigationService.navigatorKey.currentContext!
        .read<CacheProvider>()
        .cachedRangeTable![rangeId]["grids"];

    int maxRowPos = 0;
    int maxColPos = 0;
    int maxRowNeg = 0; // Row offset
    int maxColNeg = 0; // Col offset

    for (Map tile in range) {
      if (tile['row'] > maxRowPos) maxRowPos = tile['row'];
      if (tile['row'] < maxRowNeg) maxRowNeg = tile['row'];
      if (tile['col'] > maxColPos) maxColPos = tile['col'];
      if (tile['col'] < maxColNeg) maxColNeg = tile['col'];
    }

    // has to add 1 as offset because 0 is no-existen column/row
    // so in this case the offset should be XOffset = 1+XNeg
    int tileRowOffset = 1 + maxRowNeg.abs();
    int tileColOffset = 1 + maxColNeg.abs();
    int cols = maxColPos + tileColOffset;
    int rows = maxRowPos + tileRowOffset;

    List<Widget> finishedRange = List.generate(
      cols * rows, (index) => const SizedBox.square(dimension: 2), // void
    );
    for (Map tile in range) {
      int position = cols * ((tile['row'] as int) + tileRowOffset - 1) +
          ((tile['col'] as int) + tileColOffset);
      finishedRange[position - 1] = SizedBox.square(
        dimension: 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              strokeAlign: BorderSide.strokeAlignInside,
              width: 2,
            ),
          ),
        ),
      );
    }
    // 0 - 0 char
    finishedRange[cols * (tileRowOffset - 1) + tileColOffset - 1] = SizedBox.square(
      dimension: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ); // player

    final gridPadding = max(
      finishedRange.length < 20.0
          ? 16.0 -
              finishedRange.length +
              (rows > 2 ? 12.0 : 0.0) +
              (finishedRange.length == 2 ? 12.0 : 0.0) +
              (finishedRange.length == 1 ? 18.0 : 0.0) +
              (rows > 4 ? 12.0 : 0.0)
          : 40.0 - finishedRange.length + (rows > 5 ? 14.0 : 0.0),
      0.0,
    );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 90,
          width: 90,
          margin: const EdgeInsets.only(bottom: 8.0, top: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              width: 4.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    padding: EdgeInsets.fromLTRB(
                      gridPadding,
                      8.0,
                      gridPadding,
                      12.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: finishedRange,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
          child: Text(
            'Range',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: ui.FontWeight.w900,
            ),
            // ignore: deprecated_member_use
            textScaler: TextScaler.linear(
              // ignore: deprecated_member_use
              MediaQuery.textScalerOf(context).textScaleFactor + 0.1,
            ),
            textAlign: ui.TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget potTile() {
    return Column(
      children: List.generate(widget.operator.potentials.length, (index) {
        return LilButton(
          selected: index <= pot - 1,
          icon: Row(
            children: [
              Image.asset(
                'assets/pot/potential_${index + 1}_small.png',
                scale: 1.6,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.operator.potentials[index]["description"],
                  textScaler: const TextScaler.linear(0.7),
                ),
              ),
            ],
          ),
          fun: () {
            setPot(index);
          },
        );
      }),
    );
  }

  Widget rangeTile() {
    final List range = NavigationService.navigatorKey.currentContext!
        .read<CacheProvider>()
        .cachedRangeTable![widget.operator.phases[elite]["rangeId"]]["grids"];

    int maxRowPos = 0;
    int maxColPos = 0;
    int maxRowNeg = 0; // Row offset
    int maxColNeg = 0; // Col offset

    for (Map tile in range) {
      if (tile['row'] > maxRowPos) maxRowPos = tile['row'];
      if (tile['row'] < maxRowNeg) maxRowNeg = tile['row'];
      if (tile['col'] > maxColPos) maxColPos = tile['col'];
      if (tile['col'] < maxColNeg) maxColNeg = tile['col'];
    }

    // has to add 1 as offset because 0 is no-existen column/row
    // so in this case the offset should be XOffset = 1+XNeg
    int tileRowOffset = 1 + maxRowNeg.abs();
    int tileColOffset = 1 + maxColNeg.abs();
    int cols = maxColPos + tileColOffset;
    int rows = maxRowPos + tileRowOffset;

    List<Widget> finishedRange = List.generate(
      cols * rows, (index) => const SizedBox.square(dimension: 2), // void
    );
    for (Map tile in range) {
      int position = cols * ((tile['row'] as int) + tileRowOffset - 1) +
          ((tile['col'] as int) + tileColOffset);
      finishedRange[position - 1] = SizedBox.square(
        dimension: 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              strokeAlign: BorderSide.strokeAlignInside,
              width: 2,
            ),
          ),
        ),
      );
    }
    // 0 - 0 char
    finishedRange[cols * (tileRowOffset - 1) + tileColOffset - 1] = SizedBox.square(
      dimension: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ); // player

    final gridPadding = max(
      finishedRange.length < 20.0
          ? 30.0 -
              finishedRange.length +
              (rows > 2 ? 12.0 : 0.0) +
              (rows > 4 ? 12.0 : 0.0) +
              (finishedRange.length == 2 ? 12.0 : 0.0) +
              (finishedRange.length == 1 ? 18.0 : 0.0)
          : 48.0 - finishedRange.length,
      0.0,
    );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).width / 3,
          width: 120,
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              width: 4.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    padding: EdgeInsets.fromLTRB(
                      gridPadding,
                      8.0,
                      gridPadding,
                      12.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: finishedRange,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
          child: Text(
            'Range',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: ui.FontWeight.w900,
            ),
            // ignore: deprecated_member_use
            textScaler: TextScaler.linear(
              // ignore: deprecated_member_use
              MediaQuery.textScalerOf(context).textScaleFactor + 0.1,
            ),
            textAlign: ui.TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget statsBuilder() {
    return Builder(
      builder: (context) {
        List<Widget> statTiles = [
          statTile('HP', getStat('maxHp'), context),
          statTile('ATK', getStat('atk'), context),
          statTile('Redeploy', '${getStat('respawnTime')} sec', context),
          statTile('Block', getStat('blockCnt'), context),
          statTile('DEF', getStat('def'), context),
          statTile('RES', '${getStat('magicResistance')}%', context),
          statTile('DP Cost', getStat('cost'), context),
          statTile('ASPD', '${getStat('baseAttackTime')} sec', context),
        ];

        return Column(
          children: [
            Wrap(spacing: 20.0, runSpacing: 20.0, children: statTiles),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    rangeTile(),
                    Row(
                      children: [
                        LilButton(
                          selected: elite == 0,
                          fun: () {
                            selectElite(0);
                          },
                          icon: const ImageIcon(
                            AssetImage('assets/elite/elite_0.png'),
                          ),
                        ),
                        widget.operator.phases.length > 1
                            ? LilButton(
                                selected: elite == 1,
                                fun: () {
                                  selectElite(1);
                                },
                                icon: const ImageIcon(
                                  AssetImage('assets/elite/elite_1.png'),
                                ),
                              )
                            : null,
                        widget.operator.phases.length > 2
                            ? LilButton(
                                selected: elite == 2,
                                fun: () {
                                  selectElite(2);
                                },
                                icon: const ImageIcon(
                                  AssetImage('assets/elite/elite_2.png'),
                                ),
                              )
                            : null,
                      ].nullParser(),
                    ),
                  ],
                ),
                const SizedBox(width: 4.0),
                Expanded(child: potTile()),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                const Text('Trust:'),
                Expanded(
                  child: Column(
                    children: [
                      !trustMaxFlag
                          ? Slider(
                              value: sliderTrust,
                              max: 200,
                              min: 0,
                              onChanged: (value) {
                                setState(() {
                                  sliderTrust = value.roundToDouble();
                                });
                              },
                            )
                          : null,
                      Wrap(
                        spacing: 20.0,
                        runSpacing: 20.0,
                        children: getTrustBonus(),
                      ),
                    ].nullParser(),
                  ),
                ),
                LilButton(
                  icon: Text(
                    trustMaxFlag ? 'MAX' : sliderTrust.toInt().toString().padLeft(3, '  '),
                    style: const TextStyle(fontWeight: ui.FontWeight.w800),
                  ),
                  fun: () {
                    setState(() {
                      trustMaxFlag = !trustMaxFlag;
                    });
                  },
                  selected: trustMaxFlag,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 8.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Lv: '),
                Expanded(
                  child: Slider(
                    value: showLevel,
                    max: maxLevel,
                    min: 1.0,
                    divisions: maxLevel.toInt(),
                    onChanged: (value) {
                      setState(() {
                        showLevel = value.roundToDouble();
                      });
                    },
                  ),
                ),
                Text(showLevel.toInt().toString().padLeft(2, '  ')),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget talentsBuilder() {
    return Builder(
      builder: (context) {
        List<int> talentElites = [];
        List<int> talentPots = [];

        for (Map talent in widget.operator.talents) {
          for (Map candidate in talent["candidates"]) {
            int thisTalentCandidateElite = int.parse(
              (candidate["unlockCondition"]["phase"] as String).replaceFirst('PHASE_', ''),
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
        int minPot = talentPots.lastWhere((e) => e <= pot, orElse: () => talentPots.first);

        return Column(
          children: List.generate(1 + widget.operator.talents.length, (index) {
            if (index == 0) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(talentElites.length, (index) {
                      return LilButton(
                        selected: talentElites[index] == (talentLocalElite ?? minElite),
                        fun: () {
                          setState(() {
                            talentLocalElite = talentElites[index];
                          });
                        },
                        icon: ImageIcon(
                          AssetImage(
                            'assets/elite/elite_${talentElites[index]}.png',
                          ),
                        ),
                      );
                    }),
                  ),
                  Row(
                    children: List.generate(talentPots.length, (index) {
                      return LilButton(
                        selected: talentPots[index] == (talentLocalPot ?? minPot),
                        fun: () {
                          setState(() {
                            talentLocalPot = talentPots[index];
                          });
                        },
                        icon: Image.asset(
                          'assets/pot/potential_${talentPots[index]}_small.png',
                          scale: talentPots.length < 4 ? 1 : 1.5,
                        ),
                      );
                    }),
                  ),
                ],
              );
            } else {
              Map? candidate = (widget.operator.talents[index - 1]["candidates"] as List).lastWhere(
                (candidate) {
                  int thisTalentCandidateElite = int.parse(
                    (candidate["unlockCondition"]["phase"] as String).replaceFirst('PHASE_', ''),
                  );
                  int thisTalentCandidatePot = candidate["requiredPotentialRank"];
                  return (talentLocalElite ?? minElite) >= thisTalentCandidateElite &&
                      (talentLocalPot ?? minPot) >= thisTalentCandidatePot;
                },
                orElse: () => null,
              );

              if (candidate != null && candidate["isHideTalent"] == true) return null;

              bool unlocked = (candidate != null);

              currentTalentsText[index - 1] =
                  (candidate?["description"] as String?)?.akRichTextParser();

              List<Widget> extraSlots = [
                // fck tomimi
                if (candidate?["rangeId"] != null &&
                    (candidate?["blackboard"] as List).singleWhere(
                          (e) => e?["key"] == "talent_override_rangeid_flag",
                          orElse: () => null,
                        )?["value"] ==
                        1.0)
                  smolRangeTile(candidate?["rangeId"]),
                //fck summoners
                candidate?["tokenKey"] != null ? Text(candidate?["tokenKey"]) : null,
              ].nullParser();

              return Card.filled(
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
                          color: unlocked ? Theme.of(context).colorScheme.primary : null,
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
                        child: Text(
                          (widget.operator.talents[index - 1]["candidates"] as List)
                                  .first["name"] ??
                              '',
                          style: TextStyle(
                            color: unlocked
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
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
                            text: unlocked
                                ? currentTalentsText[index - 1] ?? ''
                                : '<icon src="assets/sortIcon/lock.png"/> Unlocks at Elite $index',
                            tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                            textAlign: TextAlign.start,
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
            }
          }).nullParser(),
        );
      },
    );
  }

  Widget lvSelectWidget(int lvLength, BuildContext contx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CarouselSlider(
            carouselController: carouselControllerLv,
            options: CarouselOptions(
              scrollDirection: Axis.vertical,
              onPageChanged: (int index, _) {
                setState(() {
                  skillLv = index;
                });
              },
              enableInfiniteScroll: false,
              reverse: true,
              aspectRatio: 1,
              viewportFraction: 1.0,
            ),
            items: List.generate(lvLength, (int index) {
              String label = (index < 7) ? (index + 1).toString() : "M${(index - 6).toString()}";
              return Builder(
                builder: (BuildContext context) {
                  return Center(
                    child: (index < 7)
                        ? Text(
                            label,
                            style: const TextStyle(
                              fontWeight: ui.FontWeight.w600,
                              shadows: [
                                ui.Shadow(
                                  offset: ui.Offset.zero,
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                            textScaler: const TextScaler.linear(2),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/masteries/specialized_${index - 6}_small.png',
                              ),
                              Text(
                                label,
                                style: const TextStyle(
                                  shadows: [
                                    ui.Shadow(
                                      offset: ui.Offset.zero,
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                textScaler: const TextScaler.linear(1.2),
                              ),
                            ],
                          ),
                  );
                },
              );
            }),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility.maintain(
              visible: skillLv != lvLength - 1,
              child: LilButton(
                icon: const Icon(Icons.arrow_drop_up_rounded),
                fun: () => carouselControllerLv.animateToPage(
                  skillLv + 1,
                  curve: Curves.easeOutCubic,
                ),
                padding: const EdgeInsets.all(0.0),
                backgroundColor: Theme.of(contx).colorScheme.secondaryContainer,
              ),
            ),
            Visibility.maintain(
              visible: skillLv != 0,
              child: LilButton(
                icon: const Icon(Icons.arrow_drop_down_rounded),
                fun: () => carouselControllerLv.animateToPage(
                  skillLv - 1,
                  curve: Curves.easeOutCubic,
                ),
                padding: const EdgeInsets.all(0.0),
                backgroundColor: Theme.of(contx).colorScheme.secondaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget skillBuilder() {
    // skills needs to have: maybe a custom range show,
    // maybe a custom summon show, maybe a lv upgrade diff shower (really easy to do), maybe a item cost to lvel

    Map selectedSkillDetailLv = skillsDetails[showSkill]["levels"][skillLv];
    Map selectedSkillDetail = skillsDetails[showSkill];
    Map selectedSkill = widget.operator.skills[showSkill];

    List<Widget> skillSlots = List.generate(3, (index) {
      if (widget.operator.skills.elementAtOrNull(index) != null) {
        bool selected = showSkill == index;
        return Container(
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: ui.Radius.circular(8.0)),
          ),
          child: SizedBox.square(
            dimension: 128 / 2,
            child: Stack(
              children: [
                Positioned.fill(
                  top: -20,
                  child: Text(
                    (index + 1).toString(),
                    textScaler: const TextScaler.linear(5),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.inverseSurface
                          : Theme.of(context).colorScheme.inverseSurface.withOpacity(0.7),
                      width: 1.0,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: CachedNetworkImage(
                      imageUrl:
                          '$kSkillRepo/skill_icon_${skillsDetails[index]["iconId"] ?? skillsDetails[index]["skillId"]}.png'
                              .githubEncode(),
                      color: !selected ? const ui.Color.fromARGB(255, 134, 134, 134) : null,
                      colorBlendMode: BlendMode.modulate,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        if (selected) return;
                        setState(() {
                          showSkill = index;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: const SizedBox.square(dimension: 128 / 2),
        );
      }
    });

    List<Widget> extraSlots = [
      selectedSkillDetailLv["rangeId"] != null
          ? smolRangeTile(selectedSkillDetailLv["rangeId"])
          : null,
      selectedSkill["overrideTokenKey"] != null ? Text(selectedSkill["overrideTokenKey"]) : null,
    ].nullParser();

    List<Widget> dataWidgets() {
      List<Widget?> widgets = [];
      final EdgeInsets lPadding = const EdgeInsets.all(2.0);
      final EdgeInsets lRightPadding = const EdgeInsets.only(right: 6.0);
      final double textScale = 0.8;

      // skill sp data
      widgets.add(
        switch (selectedSkillDetailLv["spData"]["spType"]) {
          "INCREASE_WITH_TIME" => Container(
              height: 40,
              width: 72,
              margin: lRightPadding,
              decoration: BoxDecoration(
                color: StaticColors.fromBrightness(context).green,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: StaticColors.fromBrightness(context).green,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Per Second Recovery',
                softWrap: true,
                textAlign: ui.TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: StaticColors.fromBrightness(context).onGreen,
                  fontWeight: ui.FontWeight.w600,
                ),
              ),
            ),
          "INCREASE_WHEN_ATTACK" => Container(
              height: 40,
              width: 72,
              margin: lRightPadding,
              decoration: BoxDecoration(
                color: StaticColors.fromBrightness(context).orange,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: StaticColors.fromBrightness(context).orange,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Offensive Recovery',
                softWrap: true,
                textAlign: ui.TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: StaticColors.fromBrightness(context).onOrange,
                  fontWeight: ui.FontWeight.w600,
                ),
              ),
            ),
          "INCREASE_WHEN_TAKEN_DAMAGE" => Container(
              height: 40,
              width: 72,
              margin: lRightPadding,
              decoration: BoxDecoration(
                color: StaticColors.fromBrightness(context).yellow,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: StaticColors.fromBrightness(context).yellow,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Deffensive Recovery',
                softWrap: true,
                textAlign: ui.TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: StaticColors.fromBrightness(context).onYellow,
                  fontWeight: ui.FontWeight.w600,
                ),
              ),
            ),
          _ => null,
        },
      );

      // skill activation type
      widgets.add(
        switch (selectedSkillDetailLv["skillType"]) {
          "MANUAL" => Container(
              height: 40,
              width: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Manual Trigger',
                softWrap: true,
                textAlign: ui.TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: ui.FontWeight.w600,
                ),
              ),
            ),
          "AUTO" => Container(
              height: 40,
              width: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Text(
                'Auto Trigger',
                softWrap: true,
                textAlign: ui.TextAlign.center,
                textScaler: TextScaler.linear(textScale),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: ui.FontWeight.w600,
                ),
              ),
            ),
          "PASSIVE" => Container(
              height: 40,
              width: 72,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  strokeAlign: BorderSide.strokeAlignInside,
                  width: 2.0,
                ),
              ),
              padding: lPadding,
              child: Center(
                child: Text(
                  'Passive',
                  softWrap: true,
                  textAlign: ui.TextAlign.center,
                  textScaler: TextScaler.linear(textScale),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: ui.FontWeight.w600,
                  ),
                ),
              ),
            ),
          _ => null,
        },
      );
      return widgets.nullParser();
    }

    List<Widget> lilDataWidgets() {
      List<Widget?> widgets = [];

      final Color textColor = Theme.of(context).colorScheme.onSecondary;
      final Color contrastColor = Theme.of(context).colorScheme.secondary;

      // skill cost
      widgets.add(
        DiffChip(
          icon: Icons.bolt,
          label: 'SP Cost',
          value:
              (skillsDetails[showSkill]["levels"][skillLv]["spData"]["spCost"] as int).toString(),
          color: textColor,
          backgroundColor: contrastColor,
          axis: skillLv == 0
              ? AxisDirection.left
              : Calc.valueDifference(
                  skillsDetails[showSkill]["levels"][skillLv]["spData"]["spCost"],
                  skillsDetails[showSkill]["levels"][skillLv - 1]["spData"]["spCost"],
                ),
        ),
      );

      // skill initial sp
      widgets.add(
        DiffChip(
          icon: Icons.play_arrow,
          label: 'Initial SP',
          value:
              (skillsDetails[showSkill]["levels"][skillLv]["spData"]["initSp"] as int).toString(),
          color: textColor,
          backgroundColor: contrastColor,
          axis: skillLv == 0
              ? AxisDirection.left
              : Calc.valueDifference(
                  skillsDetails[showSkill]["levels"][skillLv]["spData"]["initSp"],
                  skillsDetails[showSkill]["levels"][skillLv - 1]["spData"]["initSp"],
                ),
        ),
      );

      // skill duration
      widgets.add(
        switch ((selectedSkillDetailLv["durationType"] as String)) {
          "NONE" => (selectedSkillDetailLv["duration"] > 0.0)
              ? DiffChip(
                  icon: Icons.timelapse,
                  label: 'Duration',
                  value: (skillsDetails[showSkill]["levels"][skillLv]["duration"] as double)
                      .toStringAsFixed(3)
                      .replaceFirst(RegExp(r'\.?0*$'), ''),
                  color: textColor,
                  backgroundColor: contrastColor,
                  axis: skillLv == 0
                      ? AxisDirection.left
                      : Calc.valueDifference(
                          skillsDetails[showSkill]["levels"][skillLv]["duration"],
                          skillsDetails[showSkill]["levels"][skillLv - 1]["duration"],
                        ),
                )
              : null,
          "AMMO" => ((skillsDetails[showSkill]["levels"][skillLv]["blackboard"] as List).lastWhere(
                    (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                    orElse: () => null,
                  ) !=
                  null)
              ? DiffChip(
                  icon: Icons.stacked_bar_chart,
                  label: 'Ammo',
                  value: (((skillsDetails[showSkill]["levels"][skillLv]["blackboard"] as List)
                          .lastWhere(
                    (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                  ) as Map)["value"] as double)
                      .toStringAsFixed(3)
                      .replaceFirst(RegExp(r'\.?0*$'), ''),
                  color: textColor,
                  backgroundColor: contrastColor,
                  axis: skillLv == 0
                      ? AxisDirection.left
                      : Calc.valueDifference(
                          ((skillsDetails[showSkill]["levels"][skillLv]["blackboard"] as List)
                              .lastWhere(
                            (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                          ) as Map)["value"],
                          ((skillsDetails[showSkill]["levels"][skillLv - 1]["blackboard"] as List)
                              .lastWhere(
                            (i) => ((i as Map)["key"] as String).endsWith("trigger_time"),
                          ) as Map)["value"],
                        ),
                )
              : null,
          _ => null,
        },
      );

      return widgets.nullParser();
    }

    List<Widget> metadata() {
      List<Widget> widgets = [];

      final Color textColor = Colors.white60;
      final Color contrastColor = Colors.grey[800]!;

      // skill cost
      for (Map metadata in selectedSkillDetailLv["blackboard"]) {
        int index =
            (skillsDetails[showSkill]["levels"][skillLv]["blackboard"] as List).indexOf(metadata);

        widgets.add(
          DiffChip(
            label: metadata["key"],
            value: metadata["valueStr"] ?? (metadata["value"] as double).toStringWithPrecision(),
            color: textColor,
            backgroundColor: contrastColor,
            axis: skillLv == 0
                ? AxisDirection.left
                : Calc.valueDifference(
                    skillsDetails[showSkill]["levels"][skillLv]["blackboard"][index]["value"],
                    skillsDetails[showSkill]["levels"][skillLv - 1]["blackboard"][index]["value"],
                  ),
          ),
        );
      }

      return widgets;
    }

    return Builder(
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: skillSlots,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  bottomLeft: const ui.Radius.circular(8.0),
                  bottomRight: const ui.Radius.circular(8.0),
                  topRight: widget.operator.skills.length < 3
                      ? const ui.Radius.circular(8.0)
                      : Radius.zero,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              selectedSkillDetailLv["name"],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: ui.FontWeight.w800,
                              ),
                              textScaler: TextScaler.linear(
                                ((18.0 /
                                            (selectedSkillDetailLv["name"] as String)
                                                .length
                                                .toDouble()) -
                                        0.2)
                                    .clamp(1.3, 1.9),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: dataWidgets(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        width: 90,
                        height: 90,
                        child: Column(
                          children: [
                            lvSelectWidget(
                              (selectedSkillDetail["levels"] as List).length,
                              context,
                            ),
                            const Text('Skill Level'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Wrap(
                    runSpacing: 10.0,
                    spacing: 6.0,
                    children: lilDataWidgets(),
                  ),
                  const SizedBox(height: 6.0),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    child: StyledText(
                      text: (selectedSkillDetailLv["description"] as String)
                          .akRichTextParser()
                          .varParser(selectedSkillDetailLv["blackboard"]),
                      tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    child: SizedBox(
                      child: context.watch<SettingsProvider>().prefs[PrefsFlags.menuShowAdvanced]
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Wrap(
                                spacing: 6.0,
                                runSpacing: 3.0,
                                children: metadata(),
                              ),
                            )
                          : null,
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
          ],
        );
      },
    );
  }

  Widget modulesBuilder() {
    return Builder(
      builder: (context) {
        if (elite < 2) {
          return StyledText(
            text: '<icon src="assets/sortIcon/lock.png"/> Module system unlocked at Elite 2',
            tags: context.read<StyleProvider>().tagsAsArknights(context: context),
          );
        }

        final cachedTable = context.read<CacheProvider>().cachedModTable;
        final cachedstatsTable = context.read<CacheProvider>().cachedModStatsTable;
        final List<Map<String, dynamic>> modules =
            List.generate(widget.operator.modules!.length, (index) {
          return cachedTable!["equipDict"][widget.operator.modules![index]];
        });

        final Map selectedMod = modules[showMod];
        final isAdvanced = (selectedMod["type"] as String).toLowerCase() == 'advanced';
        final Map? selectedModStats = cachedstatsTable![selectedMod["uniEquipId"]];

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
        int minPot =
            modPots.lastWhere((e) => e <= pot, orElse: () => modPots.firstOrNull ?? -1) == -1
                ? 0
                : modPots.lastWhere((e) => e <= pot, orElse: () => modPots.firstOrNull ?? -1);

        if (modLocalPot != null) {
          modLocalPot = modPots.lastWhere(
                    (e) => e <= modLocalPot!,
                    orElse: () => modPots.firstOrNull ?? -1,
                  ) ==
                  -1
              ? 0
              : modPots.lastWhere(
                  (e) => e <= modLocalPot!,
                  orElse: () => modPots.firstOrNull ?? -1,
                );
        }

        void calculateChanges() {
          modAttrBuffs.clear();
          final Map? selectedModStats = cachedstatsTable[modules[showMod]["uniEquipId"]];

          if (selectedModStats?["phases"][modStage ?? minStage]["attributeBlackboard"] == null) {
            return;
          }

          for (var attribute in (selectedModStats?["phases"][modStage ?? minStage]
              ["attributeBlackboard"] as List)) {
            String name = switch (attribute['key']) {
              "respawn_time" => "respawnTime",
              "attack_speed" => "attackSpeed",
              "max_hp" => "maxHp",
              "magic_resistance" => "magicResistance",
              _ => attribute['key'],
            };
            modAttrBuffs.update(
              name,
              (value) => value + attribute['value'],
              ifAbsent: () => attribute['value'],
            );
          }
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
                      ? CachedNetworkImageProvider(
                          '$kModIconRepo/${mod["typeIcon"]}.png'.githubEncode(),
                        )
                      : const AssetImage('assets/placeholders/original.png'),
                  filterQuality: ui.FilterQuality.high,
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
                        CachedNetworkImage(
                          imageUrl:
                              '$kModImgRepo/${isAdvanced ? selectedMod["uniEquipIcon"] : 'default'}.png',
                          placeholder: (_, __) => Image.asset(
                            'assets/placeholders/module.png',
                            colorBlendMode: BlendMode.modulate,
                            color: Colors.transparent,
                          ),
                          errorWidget: (context, url, error) => Stack(
                            children: [
                              Image.asset(
                                'assets/placeholders/module.png',
                                colorBlendMode: BlendMode.modulate,
                                color: Colors.transparent,
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                              ),
                            ],
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
            final bool selected = showMod == index;

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
                            ? CachedNetworkImageProvider(
                                '$kModIconRepo/${modules[index]["typeIcon"]}.png'.githubEncode(),
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
                        onTap: () {
                          setState(() {
                            showMod = index;
                            calculateChanges();
                          });
                        },
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

          for (var attribute in (selectedModStats?["phases"][modStage ?? minStage]
              ["attributeBlackboard"] as List)) {
            result.add(
              statTile(
                Operator.statTranslate(attribute['key']),
                (attribute['value'] as double).toStringWithPrecision(),
                context,
                true,
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
          final Map selectedPhase = selectedModStats!["phases"][modStage ?? minStage];

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
                  return (modLocalPot ?? minPot) >= thisTalentCandidatePot;
                });
                changedText = ((candidate["overrideDescripton"] ?? currentTrait) +
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
                Map candidate = (part["addOrOverrideTalentDataBundle"]["candidates"] as List)
                    .lastWhere((candidate) {
                  int thisTalentCandidatePot = candidate["requiredPotentialRank"];
                  return (modLocalPot ?? minPot) >= thisTalentCandidatePot;
                });
                if (candidate["talentIndex"] < 0) continue;
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
                          curve: Curves.ease,
                          child: SizedBox(
                            width: double.maxFinite,
                            child: StyledText(
                              text: changedText,
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
                dev.log('${part["target"]} not found');
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
                leading: modIcon(modules[showMod]),
                title: Text(
                  selectedMod["uniEquipName"],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: ui.FontWeight.w800,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
                subtitle: Text(
                  joinModName(modules[showMod]),
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
                                selected: modStages[index] == (modStage ?? minStage),
                                fun: () {
                                  setState(() {
                                    modStage = modStages[index];
                                    calculateChanges();
                                  });
                                },
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
                                selected: modPots[index] == (modLocalPot ?? minPot),
                                fun: () {
                                  setState(() {
                                    modLocalPot = modPots[index];
                                    calculateChanges();
                                  });
                                },
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
                  CachedNetworkImage(
                    imageUrl:
                        '$kModImgRepo/${isAdvanced ? selectedMod["uniEquipIcon"] : 'default'}.png',
                    fit: BoxFit.none,
                    width: double.maxFinite,
                    alignment: const Alignment(-0.8, 0),
                    scale: 3.0,
                    colorBlendMode: BlendMode.modulate,
                    color: const ui.Color.fromARGB(129, 255, 255, 255),
                    placeholder: (_, __) => Image.asset(
                      'assets/placeholders/module.png',
                      colorBlendMode: BlendMode.modulate,
                      color: Colors.transparent,
                    ),
                    errorWidget: (context, url, error) => Stack(
                      children: [
                        Image.asset(
                          'assets/placeholders/module.png',
                          colorBlendMode: BlendMode.modulate,
                          color: Colors.transparent,
                          width: 100,
                          height: 100,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ],
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
                              shadows: [const ui.Shadow(blurRadius: 3.0)],
                              size: 24,
                            ),
                            alignment: ui.PlaceholderAlignment.middle,
                          ),
                          const TextSpan(text: ' Story'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: ui.FontWeight.w700,
                        shadows: [const ui.Shadow(blurRadius: 3.0)],
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
      },
    );
  }

  Widget baseSkillBuilder() {
    return Builder(
      builder: (context) {
        List<int> baseElites = [];
        List<int> baseLv = [];

        for (Map buff in widget.operator.baseSkills["buffChar"]) {
          for (Map buffdata in buff["buffData"]) {
            int thisBuffdataElite = int.parse(
              (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
            );
            if (!baseElites.contains(thisBuffdataElite)) baseElites.add(thisBuffdataElite);

            int thisBuffdataLv = buffdata["cond"]["level"];
            if (!baseLv.contains(thisBuffdataLv)) baseLv.add(thisBuffdataLv);
          }
        }
        baseElites.sort();
        baseLv.sort();

        int minElite = baseElites.lastWhere(
          (e) => e <= elite,
          orElse: () => baseElites.first,
        );
        int minLv = baseLv.lastWhere((e) => e <= showLevel.toInt(), orElse: () => baseLv.first);

        return Column(
          children:
              List.generate(1 + (widget.operator.baseSkills["buffChar"] as List).length, (index) {
            if (index == 0) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(baseElites.length, (index) {
                      return LilButton(
                        selected: baseElites[index] == (baseLocalElite ?? minElite),
                        fun: () {
                          setState(() {
                            baseLocalElite = baseElites[index];
                          });
                        },
                        icon: ImageIcon(
                          AssetImage(
                            'assets/elite/elite_${baseElites[index]}.png',
                          ),
                        ),
                      );
                    }),
                  ),
                  Row(
                    children: List.generate(baseLv.length, (index) {
                      return LilButton(
                        selected: baseLv[index] == (baseLocalLv ?? minLv),
                        fun: () {
                          setState(() {
                            baseLocalLv = baseLv[index];
                          });
                        },
                        icon: Text.rich(
                          textScaler: const TextScaler.linear(0.8),
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Lv', style: TextStyle(fontSize: 10)),
                              TextSpan(text: baseLv[index].toString()),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            } else {
              if ((widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).isEmpty) {
                return null;
              }

              final Map? buffData =
                  (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).lastWhere(
                (buffdata) {
                  int thisBuffdataElite = int.parse(
                    (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
                  );
                  int thisBuffdataLv = buffdata["cond"]["level"];
                  return (baseLocalElite ?? minElite) >= thisBuffdataElite &&
                      (baseLocalLv ?? minLv) >= thisBuffdataLv;
                },
                orElse: () => null,
              );

              final bool unlocked = (buffData != null);
              final String buffId =
                  (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).lastWhere(
                (buffdata) {
                  int thisBuffdataElite = int.parse(
                    (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
                  );
                  int thisBuffdataLv = buffdata["cond"]["level"];
                  return (baseLocalElite ?? minElite) >= thisBuffdataElite &&
                      (baseLocalLv ?? minLv) >= thisBuffdataLv;
                },
                orElse: () =>
                    (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List).first,
              )["buffId"];

              final int textelite = int.parse(
                ((widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List)
                        .first["cond"]["phase"] as String)
                    .replaceFirst('PHASE_', ''),
              );
              final int textlv =
                  (widget.operator.baseSkills["buffChar"][index - 1]["buffData"] as List)
                      .first["cond"]["level"];

              final cachedTable = context.read<CacheProvider>().cachedBaseSkillTable;
              final Color? bgColor =
                  unlocked ? (cachedTable![buffId]["buffColor"] as String).parseAsHex() : null;
              final Color textColor = unlocked
                  ? (cachedTable![buffId]["textColor"] as String).parseAsHex()
                  : Theme.of(context).colorScheme.onSurface;

              return Card.filled(
                margin: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            padding: EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                              right: 12.0,
                              left: unlocked ? 35 : 12.0,
                            ),
                            child: Text(
                              (cachedTable![buffId]["buffName"] as String?) ?? '',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: unlocked
                                      ? Theme.of(context).colorScheme.outline
                                      : Colors.transparent,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CachedNetworkImage(
                                  colorBlendMode: BlendMode.modulate,
                                  imageUrl:
                                      '$kBaseSkillRepo/${cachedTable[buffId]["skillIcon"]}.png'
                                          .githubEncode(),
                                  scale: 1.3,
                                  color: unlocked ? null : Colors.transparent,
                                  placeholder: (_, __) => Image.asset(
                                    'assets/placeholders/baseskill.png',
                                    colorBlendMode: BlendMode.modulate,
                                    color: Colors.transparent,
                                    scale: 1.3,
                                  ),
                                  errorWidget: (context, url, error) => Stack(
                                    children: [
                                      Image.asset(
                                        'assets/placeholders/baseskill.png',
                                        colorBlendMode: BlendMode.modulate,
                                        color: Colors.transparent,
                                        scale: 1.3,
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Theme.of(context).colorScheme.surface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.ease,
                        child: SizedBox(
                          width: double.maxFinite,
                          child: StyledText(
                            text: unlocked
                                ? ((cachedTable[buffId]["description"] ?? '') as String)
                                    .akRichTextParser()
                                : '<icon src="assets/sortIcon/lock.png"/> Unlocks at Elite ${textelite.toString()} lv${textlv.toString()}',
                            tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ].nullParser(),
                  ),
                ),
              );
            }
          }).nullParser(),
        );
      },
    );
  }
}

class ArchivePage extends StatefulWidget {
  final Operator operator;
  const ArchivePage(this.operator, {super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

List<Operator>? computingRelatedOps(List input) {
  List<Operator>? result;
  List<dynamic>? opGroup; // List<String>

  if (input[4]) {
    for (Map group in (input[3]["infos"] as Map<String, dynamic>).values) {
      if ((group["tmplIds"] as List).contains(input[0])) {
        opGroup = group["tmplIds"];
        break;
      }
    }
  } else {
    for (List group in (input[1]["spCharGroups"] as Map<String, dynamic>).values) {
      if (group.contains(input[0])) {
        opGroup = group;
        break;
      }
    }
  }
  if (opGroup == null || opGroup.length <= 1) return result;

  result = [];

  for (final opId in opGroup) {
    if (opId == input[0]) continue;

    final relOp = (input[2] as List<Operator>).singleWhere((element) => element.id == opId);

    result.add(relOp);
  }

  return result;
}

class _ArchivePageState extends State<ArchivePage> with SingleTickerProviderStateMixin {
  late TabController _secondaryTabController;
  late final List<Widget> _secChildren;
  int _activeIndex = 0;
  final List<Tab> _secTabs = <Tab>[
    const Tab(text: 'Combat'),
    const Tab(text: 'File'),
  ];

  late Future<List<Operator>?> relatedOperatorList;

  @override
  void initState() {
    super.initState();

    relatedOperatorList = getRelatedOps();

    _secondaryTabController = TabController(vsync: this, length: _secTabs.length);
    _secondaryTabController.addListener(() {
      setState(() {
        _activeIndex = _secondaryTabController.index;
      });
    });

    _secChildren = [SkillInfo(widget.operator), LoreInfo(widget.operator)];
  }

  Future<List<Operator>?> getRelatedOps() async {
    final charMeta =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedCharMeta;
    final charPatch =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedCharPatch;
    final opList =
        NavigationService.navigatorKey.currentContext!.read<CacheProvider>().cachedListOperator;
    final bool opHasPatch = widget.operator.opPatched;

    final List input = [widget.operator.id, charMeta, opList, charPatch, opHasPatch];

    return await compute(computingRelatedOps, input);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: relatedOperatorList,
      builder: (context, snapshot) {
        if (snapshot.hasError) throw snapshot.error!; //  Error

        Widget relatedOperatorHeader = (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null)
            ? SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'Related Operators: ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: ui.FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            snapshot.data!.length,
                            (index) {
                              return OperatorLilCard(operator: snapshot.data![index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(
                height: 0,
                width: double.maxFinite,
              );

        return CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
                  ? TranslucentWidget(
                      child: FlexibleSpaceBar(
                        title: Text(widget.operator.name),
                        titlePadding: const EdgeInsets.only(
                          left: 72.0,
                          bottom: 16.0,
                          right: 32.0,
                        ),
                      ),
                    )
                  : FlexibleSpaceBar(
                      title: Text(widget.operator.name),
                      titlePadding: const EdgeInsets.only(
                        left: 72.0,
                        bottom: 16.0,
                        right: 32.0,
                      ),
                    ),
              backgroundColor: context.read<UiProvider>().useTranslucentUi == true
                  ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
                  : null,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                MenuAnchor(
                  menuChildren: [
                    SwitchListTile(
                      value: context.watch<SettingsProvider>().prefs[PrefsFlags.menuShowAdvanced],
                      onChanged: (bool value) {
                        context
                            .read<SettingsProvider>()
                            .setAndSaveBoolPref(PrefsFlags.menuShowAdvanced, value);
                      },
                      title: const Text('Show advanced'),
                    ),
                  ],
                  builder: (
                    BuildContext context,
                    MenuController controller,
                    Widget? child,
                  ) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_horiz),
                    );
                  },
                ),
              ],
            ),
            SliverList.list(
              children: [
                HeaderInfo(
                  operator: widget.operator,
                  relatedOps: relatedOperatorHeader,
                ),
                TabBar.secondary(
                  controller: _secondaryTabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: _secTabs,
                ),
                const SizedBox(height: 20),
              ],
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return AnimatedSwitcher.defaultTransitionBuilder(
                    child,
                    animation,
                  );
                },
                child: _secChildren[_activeIndex],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        );
      },
    );
  }
}
