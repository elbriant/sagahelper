import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

class OperatorTalents extends StatelessWidget {
  const OperatorTalents({
    super.key,
    required this.operator,
    required this.currentElite,
    required this.currentPot,
    this.localTalentElite,
    this.localTalentPot,
    required this.localTalentEliteSetter,
    required this.localTalentPotSetter,
  });
  final Operator operator;
  final int currentElite;
  final int currentPot;
  final int? localTalentElite;
  final int? localTalentPot;

  final ValueSetter<int> localTalentEliteSetter;
  final ValueSetter<int> localTalentPotSetter;

  @override
  Widget build(BuildContext context) {
    List<int> talentElites = [];
    List<int> talentPots = [];

    for (Map talent in operator.talents) {
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
      (e) => e <= currentElite,
      orElse: () => talentElites.first,
    );
    int minPot = talentPots.lastWhere((e) => e <= currentPot, orElse: () => talentPots.first);

    return Column(
      children: List.generate(1 + operator.talents.length, (index) {
        if (index == 0) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(talentElites.length, (index) {
                  return LilButton(
                    selected: talentElites[index] == (localTalentElite ?? minElite),
                    fun: () => localTalentEliteSetter.call(talentElites[index]),
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
                    selected: talentPots[index] == (localTalentPot ?? minPot),
                    fun: () => localTalentPotSetter.call(talentPots[index]),
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
          Map? candidate = (operator.talents[index - 1]["candidates"] as List).lastWhere(
            (candidate) {
              int thisTalentCandidateElite = int.parse(
                (candidate["unlockCondition"]["phase"] as String).replaceFirst('PHASE_', ''),
              );
              int thisTalentCandidatePot = candidate["requiredPotentialRank"];
              return (localTalentElite ?? minElite) >= thisTalentCandidateElite &&
                  (localTalentPot ?? minPot) >= thisTalentCandidatePot;
            },
            orElse: () => null,
          );

          if (candidate != null && candidate["isHideTalent"] == true) return null;

          bool unlocked = (candidate != null);

          final talentText = (candidate?["description"] as String?)?.akRichTextParser();

          List<Widget> extraSlots = [
            // fck tomimi
            if (candidate?["rangeId"] != null &&
                (candidate?["blackboard"] as List).singleWhere(
                      (e) => e?["key"] == "talent_override_rangeid_flag",
                      orElse: () => null,
                    )?["value"] ==
                    1.0)
              RangeTile.smol(candidate?["rangeId"]),
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
                      (operator.talents[index - 1]["candidates"] as List).first["name"] ?? '',
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
                            ? talentText ?? ''
                            : '<icon src="assets/sortIcon/lock.png"/> Unlocks at Elite $index',
                        tags: context.read<StyleProvider>().tagsAsArknights(context: context),
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
        }
      }).nullParser(),
    );
  }
}
