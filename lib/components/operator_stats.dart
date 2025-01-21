import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/potentials_tile.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/stat_tile.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class OperatorStats extends StatelessWidget {
  const OperatorStats({
    super.key,
    required this.operator,
    required this.currentlevel,
    required this.maxLevel,
    required this.currentElite,
    required this.maxTrustFlag,
    required this.currentTrust,
    required this.modAttributesBuffs,
    required this.potAttributesBuffs,
    required this.currentPot,
    required this.eliteSetter,
    required this.potSetter,
    required this.trustSliderSetter,
    required this.maxTrustFlagToggle,
    required this.levelSetter,
  });

  final Operator operator;
  final double currentlevel;
  final double maxLevel;
  final int currentElite;
  final bool maxTrustFlag;
  final double currentTrust;
  final Map<String, double> modAttributesBuffs;
  final Map<String, double> potAttributesBuffs;
  final int currentPot;

  final ValueSetter<int> eliteSetter;
  final ValueSetter<int> potSetter;
  final ValueSetter<double> trustSliderSetter;
  final VoidCallback maxTrustFlagToggle;
  final ValueSetter<double> levelSetter;

  double getSingleTrustBonus(String stat) {
    if (maxTrustFlag) {
      var val = operator.favorKeyframes[1]["data"][stat];
      return val.runtimeType == int ? (val as int).toDouble() : val;
    } else {
      var val = lerpDouble(
        operator.favorKeyframes[0]["data"][stat].runtimeType == int
            ? (operator.favorKeyframes[0]["data"][stat] as int).toDouble()
            : operator.favorKeyframes[0]["data"][stat],
        operator.favorKeyframes[1]["data"][stat].runtimeType == int
            ? (operator.favorKeyframes[1]["data"][stat] as int).toDouble()
            : operator.favorKeyframes[1]["data"][stat],
        currentTrust.clamp(
              0.0,
              (operator.favorKeyframes[1]["level"] as int).toDouble(),
            ) /
            (operator.favorKeyframes[1]["level"] as int).toDouble(),
      )!;
      return val;
    }
  }

  String getStat(String stat) {
    List<dynamic> datakeyframe = operator.phases[currentElite]['attributesKeyFrames'];

    if (stat == 'baseAttackTime' || stat == 'respawnTime') {
      var value = lerpDouble(
        datakeyframe[0]['data'][stat],
        datakeyframe[1]['data'][stat],
        (currentlevel - 1.0) / (maxLevel - 1),
      )!;
      value += getSingleTrustBonus(stat);
      if (stat == 'baseAttackTime') {
        //shown value is atk interval, here we calculate the interval with the real ASPD
        value /= ((lerpDouble(
                  datakeyframe[0]['data']['attackSpeed'],
                  datakeyframe[1]['data']['attackSpeed'],
                  (currentlevel - 1.0) / (maxLevel - 1),
                )! +
                (potAttributesBuffs.containsKey("attackSpeed")
                    ? potAttributesBuffs["attackSpeed"]!
                    : 0.0) +
                (modAttributesBuffs.containsKey("attackSpeed")
                    ? modAttributesBuffs["attackSpeed"]!
                    : 0.0)) /
            100);
      }
      if (stat == 'respawnTime' && potAttributesBuffs.containsKey('respawnTime')) {
        value += potAttributesBuffs['respawnTime']!;
      }
      if (stat == 'respawnTime' && modAttributesBuffs.containsKey('respawnTime')) {
        value += modAttributesBuffs['respawnTime']!;
      }
      // prettify
      return value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0*$'), '');
    } else {
      var value = lerpDouble(
        datakeyframe[0]['data'][stat],
        datakeyframe[1]['data'][stat],
        (currentlevel - 1.0) / (maxLevel - 1),
      )!;
      value += getSingleTrustBonus(stat);
      if (potAttributesBuffs.containsKey(stat)) value += potAttributesBuffs[stat]!;
      if (modAttributesBuffs.containsKey(stat)) value += modAttributesBuffs[stat]!;
      return value.round().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> statTiles = [
      StatTile(stat: 'HP', value: getStat('maxHp')),
      StatTile(stat: 'ATK', value: getStat('atk')),
      StatTile(stat: 'Redeploy', value: '${getStat('respawnTime')} sec'),
      StatTile(stat: 'Block', value: getStat('blockCnt')),
      StatTile(stat: 'DEF', value: getStat('def')),
      StatTile(stat: 'RES', value: '${getStat('magicResistance')}%'),
      StatTile(stat: 'DP Cost', value: getStat('cost')),
      StatTile(stat: 'ASPD', value: '${getStat('baseAttackTime')} sec'),
    ];

    List<Widget> getTrustBonus() {
      var result = <Widget>[];

      (operator.favorKeyframes[1]["data"] as Map).forEach((key, value) {
        if (value.runtimeType == int || value.runtimeType == double) {
          if (value == 0) return;
          var val = value.runtimeType == int ? (value as int).toDouble() : value;

          if (!maxTrustFlag) {
            val = lerpDouble(
              operator.favorKeyframes[0]["data"][key],
              value,
              currentTrust.clamp(
                    0.0,
                    (operator.favorKeyframes[1]["level"] as int).toDouble(),
                  ) /
                  (operator.favorKeyframes[1]["level"] as int).toDouble(),
            )!;
          }
          val = (val as double).round();
          if (val == 0) return;

          result.add(
            StatTile(
              stat: Operator.statTranslate(key),
              value: val.toString(),
              isBonus: true,
            ),
          );
        } else {
          if (value == false) return;
          if (!maxTrustFlag &&
              currentTrust < (operator.favorKeyframes[1]["level"] as int).toDouble()) return;

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

    return Column(
      children: [
        Wrap(spacing: 20.0, runSpacing: 20.0, children: statTiles),
        const SizedBox(height: 20.0),
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RangeTile(
                  rangeGrids: context
                      .read<CacheProvider>()
                      .cachedRangeTable![operator.phases[currentElite]["rangeId"]]["grids"],
                ),
                Row(
                  children: [
                    LilButton(
                      selected: currentElite == 0,
                      fun: () => eliteSetter.call(0),
                      icon: const ImageIcon(
                        AssetImage('assets/elite/elite_0.png'),
                      ),
                    ),
                    operator.phases.length > 1
                        ? LilButton(
                            selected: currentElite == 1,
                            fun: () => eliteSetter.call(1),
                            icon: const ImageIcon(
                              AssetImage('assets/elite/elite_1.png'),
                            ),
                          )
                        : null,
                    operator.phases.length > 2
                        ? LilButton(
                            selected: currentElite == 2,
                            fun: () => eliteSetter.call(2),
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
            Expanded(
              child: PotentialsTile(
                operator: operator,
                currentPot: currentPot,
                potSetter: potSetter,
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
                          value: currentTrust,
                          max: 200,
                          min: 0,
                          onChanged: (value) => trustSliderSetter.call(value.roundToDouble()),
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
                maxTrustFlag ? 'MAX' : currentTrust.toInt().toString().padLeft(3, '  '),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              fun: maxTrustFlagToggle,
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
                value: currentlevel,
                max: maxLevel,
                min: 1.0,
                divisions: maxLevel.toInt(),
                onChanged: (value) => levelSetter.call(value.roundToDouble()),
              ),
            ),
            Text(currentlevel.toInt().toString().padLeft(2, '  ')),
          ],
        ),
      ],
    );
  }
}
