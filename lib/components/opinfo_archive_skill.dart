import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/big_title_text.dart';
import 'package:sagahelper/components/operator_base_skill.dart';
import 'package:sagahelper/components/operator_modules.dart';
import 'package:sagahelper/components/operator_skill.dart';
import 'package:sagahelper/components/operator_stats.dart';
import 'package:sagahelper/components/operator_talents.dart';
import 'package:sagahelper/components/trait_card.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:styled_text/styled_text.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:flutter/material.dart';

class OpinfoArchiveSkill extends StatefulWidget {
  final Operator operator;
  const OpinfoArchiveSkill(this.operator, {super.key});

  @override
  State<OpinfoArchiveSkill> createState() => _OpinfoArchiveSkillState();
}

class _OpinfoArchiveSkillState extends State<OpinfoArchiveSkill> {
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
    super.initState();
    _init();
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
                        async: true,
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
            child: OperatorStats(
              operator: widget.operator,
              currentlevel: showLevel,
              maxLevel: maxLevel,
              currentElite: elite,
              maxTrustFlag: trustMaxFlag,
              currentTrust: sliderTrust,
              modAttributesBuffs: modAttrBuffs,
              potAttributesBuffs: potBuffs,
              currentPot: pot,
              eliteSetter: (value) => setState(() {
                talentLocalElite = null;
                if (elite == value) return;
                elite = value;
                maxLevel = (widget.operator.phases[elite]["maxLevel"] as int).toDouble();
                showLevel = showLevel.clamp(1, maxLevel);
              }),
              potSetter: (value) => setState(() {
                if (pot == value + 1) {
                  pot -= 1;
                } else {
                  pot = value + 1;
                }
                talentLocalPot = null;
                calcPotBonuses();
              }),
              trustSliderSetter: (value) => setState(() {
                sliderTrust = value.roundToDouble();
              }),
              maxTrustFlagToggle: () => setState(() {
                trustMaxFlag = !trustMaxFlag;
              }),
              levelSetter: (value) => setState(() {
                showLevel = value.roundToDouble();
              }),
            ),
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
            child: OperatorTalents(
              operator: widget.operator,
              currentElite: elite,
              currentPot: pot,
              localTalentElite: talentLocalElite,
              localTalentPot: talentLocalPot,
              localTalentEliteSetter: (value) => setState(() {
                talentLocalElite = value;
              }),
              localTalentPotSetter: (value) => setState(() {
                talentLocalPot = value;
              }),
            ),
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
                      child: OperatorSkill(
                        operator: widget.operator,
                        skillsDetails: skillsDetails,
                        currentSelectedSkill: showSkill,
                        currentSkillLevel: skillLv,
                        onSkillLevelChanged: (value) => setState(() {
                          skillLv = value;
                        }),
                        onSkillSelectedSetter: (value) => setState(() {
                          showSkill = value;
                        }),
                      ),
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
                      child: OperatorModules(
                        operator: widget.operator,
                        currentElite: elite,
                        currentPot: pot,
                        currentModuleSelected: showMod,
                        currentTrait: currentTrait,
                        modAttributesBuffs: modAttrBuffs,
                        currentModStage: modStage,
                        localModPotential: modLocalPot,
                        onLocalModPotentialChanged: (value, attr) => setState(() {
                          modLocalPot = value;
                          modAttrBuffs = attr;
                        }),
                        onModChanged: (value, attr) => setState(() {
                          showMod = value;
                          modAttrBuffs = attr;
                        }),
                        onModStageChanged: (value, attr) => setState(() {
                          modStage = value;
                          modAttrBuffs = attr;
                        }),
                      ),
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
                      child: OperatorBaseSkill(
                        operator: widget.operator,
                        currentElite: elite,
                        currentLevel: showLevel,
                        localBaseLevel: baseLocalLv,
                        localBaseElite: baseLocalElite,
                        onLocalBaseEliteChanged: (value) => setState(() {
                          baseLocalElite = value;
                        }),
                        onLocalBaseLevelChanged: (value) => setState(() {
                          baseLocalLv = value;
                        }),
                      ),
                    ),
                  ],
                )
              : null,
        ].nullParser(),
      ),
    );
  }
}
