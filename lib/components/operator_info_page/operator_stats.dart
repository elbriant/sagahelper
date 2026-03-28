import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sagahelper/components/potentials_tile.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/components/stat_tile.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/core/snack_bar_service.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/operator_context_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class OperatorStats extends ConsumerStatefulWidget {
  const OperatorStats({
    super.key,
    required this.operator,
  });

  final Operator operator;

  @override
  ConsumerState<OperatorStats> createState() => _OperatorStatsState();
}

class _OperatorStatsState extends ConsumerState<OperatorStats> {
  double trust = 0.0;
  bool maxTrustFlag = true;
  bool changingLevel = false;
  Map<String, double> potAttributesBuffs = {};
  bool loaded = false;

  late int currentElite;
  late double currentLevel;
  late double maxLevel;
  late Map<String, double> modAttributesBuffs;
  late int currentPot;

  @override
  void initState() {
    super.initState();
    trust = (widget.operator.favorKeyframes[1]["level"] as int).toDouble();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          loaded = true;
        });
      });
    });
  }

  Map<String, double> calcPotBonuses(int pot) {
    Map<String, double> potBuffs = {};

    for (Map potDetail in widget.operator.potentials) {
      if (widget.operator.potentials.indexOf(potDetail) > pot - 1) break;

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
          SnackBarService.showSnackBar(
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

    return potBuffs;
  }

  List<Widget> getTrustBonus() {
    var result = <Widget>[];

    (widget.operator.favorKeyframes[1]["data"] as Map).forEach((key, value) {
      if (value is num) {
        double val = value.toDouble();
        if (val == 0.0) return;

        if (!maxTrustFlag) {
          val = lerpDouble(
            widget.operator.favorKeyframes[0]["data"][key],
            value,
            min(trust, (widget.operator.favorKeyframes[1]["level"] as num).toDouble()) /
                (widget.operator.favorKeyframes[1]["level"] as num).toDouble(),
          )!;
        }

        val = val.roundToDouble();
        if (val == 0.0) return;

        result.add(
          StatTile(
            stat: Operator.statTranslate(key),
            value: val.toStringWithPrecision(1),
            isBonus: true,
          ),
        );
      } else {
        if (value == false) return;
        if (!maxTrustFlag &&
            trust < (widget.operator.favorKeyframes[1]["level"] as int).toDouble()) {
          return;
        }

        result.add(
          StatTile(
            stat: Operator.statTranslate(key),
            value: '',
            isBonus: true,
          ),
        );
      }
    });

    return result;
  }

  double getSingleTrustBonus(String stat) {
    if (maxTrustFlag) {
      return (widget.operator.favorKeyframes[1]["data"][stat] as num).roundToDouble();
    }

    return lerpDouble(
      (widget.operator.favorKeyframes[0]["data"][stat] as num).toDouble(),
      (widget.operator.favorKeyframes[1]["data"][stat] as num).toDouble(),
      min(trust, (widget.operator.favorKeyframes[1]["level"] as num).toDouble()) /
          (widget.operator.favorKeyframes[1]["level"] as num).toDouble(),
    )!
        .roundToDouble();
  }

  String getStat(String stat) {
    List<dynamic> datakeyframe = widget.operator.phases[currentElite]['attributesKeyFrames'];

    if (stat == 'baseAttackTime' || stat == 'respawnTime') {
      var value = lerpDouble(
        datakeyframe[0]['data'][stat],
        datakeyframe[1]['data'][stat],
        (currentLevel - 1.0) / (maxLevel - 1),
      )!;
      value += getSingleTrustBonus(stat);
      value += potAttributesBuffs[stat] ?? 0;
      value += modAttributesBuffs[stat] ?? 0;

      if (stat == 'baseAttackTime') {
        //shown value is atk interval, here we calculate the interval with the real ASPD
        double aspd = lerpDouble(
          datakeyframe[0]['data']['attackSpeed'],
          datakeyframe[1]['data']['attackSpeed'],
          (currentLevel - 1.0) / (maxLevel - 1),
        )!;

        aspd += potAttributesBuffs["attackSpeed"] ?? 0;
        aspd += modAttributesBuffs["attackSpeed"] ?? 0;

        value /= aspd / 100;
      }

      // pretty string
      return value.toStringWithPrecision(3);
    } else {
      var value = lerpDouble(
        datakeyframe[0]['data'][stat],
        datakeyframe[1]['data'][stat],
        (currentLevel - 1.0) / (maxLevel - 1),
      )!;
      value += getSingleTrustBonus(stat);
      if (potAttributesBuffs.containsKey(stat)) value += potAttributesBuffs[stat]!;
      if (modAttributesBuffs.containsKey(stat)) value += modAttributesBuffs[stat]!;
      return value.round().toString();
    }
  }

  void setElite(int value) {
    if (currentElite == value) return;
    // wont require setState as build depends on this so it will rebuild anyways
    ref
        .read(operatorContextProvider.notifier)
        .setElite(value, (widget.operator.phases[value]["maxLevel"] as int).toDouble());
  }

  void setTrust(double value) {
    setState(() {
      trust = value;
    });
  }

  void setLevel(double value) {
    setState(() {
      currentLevel = value;
    });
  }

  void setPotential(int value) {
    final int pot = (currentPot == value + 1) ? currentPot - 1 : value + 1;
    potAttributesBuffs = calcPotBonuses(pot);

    // do not require setState as context.read().setPotential
    // will rebuild anyways
    ref.read(operatorContextProvider.notifier).update(
          (state) => state.copyWith(potential: pot),
        );
  }

  void toggleTrustFlag() {
    setState(() {
      maxTrustFlag = !maxTrustFlag;
    });
  }

  @override
  Widget build(BuildContext context) {
    currentElite = ref.watch(operatorContextProvider.select((p) => p.elite));
    if (!changingLevel) {
      currentLevel = ref.watch(operatorContextProvider.select((p) => p.level));
    }
    maxLevel = ref.watch(operatorContextProvider.select((p) => p.maxLevel));
    modAttributesBuffs = ref.watch(operatorContextProvider.select((p) => p.modAttrBuffs));
    currentPot = ref.watch(operatorContextProvider.select((p) => p.potential));

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: !loaded
          ? ShimmerLoadingMask(
              child: Container(
                margin: const EdgeInsets.only(top: 6.0, bottom: 18.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: double.maxFinite,
                height: 490,
              ),
            )
          : Container(
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: [
                      StatTile(stat: 'HP', value: getStat('maxHp')),
                      StatTile(stat: 'ATK', value: getStat('atk')),
                      StatTile(stat: 'Redeploy', value: '${getStat('respawnTime')} sec'),
                      StatTile(stat: 'Block', value: getStat('blockCnt')),
                      StatTile(stat: 'DEF', value: getStat('def')),
                      StatTile(stat: 'RES', value: '${getStat('magicResistance')}%'),
                      StatTile(stat: 'DP Cost', value: getStat('cost')),
                      StatTile(stat: 'ASPD', value: '${getStat('baseAttackTime')} sec'),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RangeTile(
                            rangeId: widget.operator.phases[currentElite]["rangeId"],
                          ),
                          Row(
                            children: [
                              LilButton(
                                selected: currentElite == 0,
                                fun: () => setElite(0),
                                icon: ImageIcon(
                                  const AssetImage('assets/elite/elite_0.png'),
                                  color: Colors.grey[200],
                                ),
                              ),
                              if (widget.operator.phases.length > 1)
                                LilButton(
                                  selected: currentElite == 1,
                                  fun: () => setElite(1),
                                  icon: ImageIcon(
                                    const AssetImage('assets/elite/elite_1.png'),
                                    color: Colors.grey[200],
                                  ),
                                ),
                              if (widget.operator.phases.length > 2)
                                LilButton(
                                  selected: currentElite == 2,
                                  fun: () => setElite(2),
                                  icon: ImageIcon(
                                    const AssetImage('assets/elite/elite_2.png'),
                                    color: Colors.grey[200],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: PotentialsTile(
                          operator: widget.operator,
                          currentPot: currentPot,
                          potSetter: setPotential,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      const Text('Trust:'),
                      Expanded(
                        child: Column(
                          children: [
                            !maxTrustFlag
                                ? Slider(
                                    value: trust,
                                    max: 200,
                                    min: 0,
                                    onChanged: (value) => setTrust(value.roundToDouble()),
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
                          maxTrustFlag ? 'MAX' : trust.toStringAsFixed(0).padLeft(3, '  '),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        fun: toggleTrustFlag,
                        selected: maxTrustFlag,
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
                          value: currentLevel,
                          max: maxLevel,
                          min: 1.0,
                          divisions: maxLevel.toInt(),
                          onChangeStart: (value) {
                            changingLevel = true;
                            setLevel(value.roundToDouble());
                          },
                          onChanged: (value) => setLevel(value.roundToDouble()),
                          onChangeEnd: (value) {
                            changingLevel = false;
                            ref.read(operatorContextProvider.notifier).update(
                                  (s) => s.copyWith(level: value.roundToDouble()),
                                );
                          },
                        ),
                      ),
                      Text(currentLevel.toStringAsFixed(0).padLeft(2, '  ')),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
