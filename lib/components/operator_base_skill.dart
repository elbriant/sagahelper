import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

class OperatorBaseSkill extends StatelessWidget {
  const OperatorBaseSkill({
    super.key,
    required this.operator,
    required this.currentElite,
    required this.currentLevel,
    this.localBaseElite,
    this.localBaseLevel,
    required this.onLocalBaseEliteChanged,
    required this.onLocalBaseLevelChanged,
  });

  final Operator operator;
  final int currentElite;
  final double currentLevel;
  final int? localBaseElite;
  final int? localBaseLevel;

  final ValueChanged<int> onLocalBaseEliteChanged;
  final ValueChanged<int> onLocalBaseLevelChanged;

  @override
  Widget build(BuildContext context) {
    List<int> baseElites = [];
    List<int> baseLv = [];

    for (Map buff in operator.baseSkills["buffChar"]) {
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
      (e) => e <= currentElite,
      orElse: () => baseElites.first,
    );
    int minLv = baseLv.lastWhere((e) => e <= currentLevel.toInt(), orElse: () => baseLv.first);

    return Column(
      children: List.generate(1 + (operator.baseSkills["buffChar"] as List).length, (index) {
        if (index == 0) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(baseElites.length, (index) {
                  return LilButton(
                    selected: baseElites[index] == (localBaseElite ?? minElite),
                    fun: () => onLocalBaseEliteChanged.call(baseElites[index]),
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
                    selected: baseLv[index] == (localBaseLevel ?? minLv),
                    fun: () => onLocalBaseLevelChanged.call(baseLv[index]),
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
          if ((operator.baseSkills["buffChar"][index - 1]["buffData"] as List).isEmpty) {
            return null;
          }

          final Map? buffData =
              (operator.baseSkills["buffChar"][index - 1]["buffData"] as List).lastWhere(
            (buffdata) {
              int thisBuffdataElite = int.parse(
                (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
              );
              int thisBuffdataLv = buffdata["cond"]["level"];
              return (localBaseElite ?? minElite) >= thisBuffdataElite &&
                  (localBaseLevel ?? minLv) >= thisBuffdataLv;
            },
            orElse: () => null,
          );

          final bool unlocked = (buffData != null);
          final String buffId =
              (operator.baseSkills["buffChar"][index - 1]["buffData"] as List).lastWhere(
            (buffdata) {
              int thisBuffdataElite = int.parse(
                (buffdata["cond"]["phase"] as String).replaceFirst('PHASE_', ''),
              );
              int thisBuffdataLv = buffdata["cond"]["level"];
              return (localBaseElite ?? minElite) >= thisBuffdataElite &&
                  (localBaseLevel ?? minLv) >= thisBuffdataLv;
            },
            orElse: () => (operator.baseSkills["buffChar"][index - 1]["buffData"] as List).first,
          )["buffId"];

          final int textelite = int.parse(
            ((operator.baseSkills["buffChar"][index - 1]["buffData"] as List).first["cond"]["phase"]
                    as String)
                .replaceFirst('PHASE_', ''),
          );
          final int textlv = (operator.baseSkills["buffChar"][index - 1]["buffData"] as List)
              .first["cond"]["level"];

          final cachedTable =
              context.select<CacheProvider, Map<String, dynamic>>((p) => p.cachedBaseSkillTable!);

          final Color? bgColor =
              unlocked ? (cachedTable[buffId]["buffColor"] as String).parseAsHex() : null;
          final Color textColor = unlocked
              ? (cachedTable[buffId]["textColor"] as String).parseAsHex()
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
                          (cachedTable[buffId]["buffName"] as String?) ?? '',
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
                            child: StoredImage(
                              colorBlendMode: BlendMode.modulate,
                              imageUrl: '$kBaseSkillRepo/${cachedTable[buffId]["skillIcon"]}.png'
                                  .githubEncode(),
                              filePath: 'baseicon/${cachedTable[buffId]["skillIcon"]}.png',
                              scale: 1.3,
                              color: unlocked ? null : Colors.transparent,
                              placeholder: Image.asset(
                                'assets/placeholders/baseskill.png',
                                colorBlendMode: BlendMode.modulate,
                                color: Colors.transparent,
                                scale: 1.3,
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
                        async: true,
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
  }
}
