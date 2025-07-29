// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/op_info_provider.dart';
import 'package:styled_text/styled_text.dart';

import 'package:sagahelper/components/entity_card.dart';
import 'package:sagahelper/components/range_tile.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/models/entity.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class OperatorTalents extends StatefulWidget {
  const OperatorTalents({
    super.key,
    required this.operator,
  });
  final Operator operator;

  @override
  State<OperatorTalents> createState() => _OperatorTalentsState();
}

class _OperatorTalentsState extends State<OperatorTalents> {
  int? localElite;
  int? localPotential;
  List<int> talentElites = [];
  List<int> talentPots = [];

  late int currentElite;
  late int currentPotential;

  @override
  void initState() {
    super.initState();
    currentElite = context.read<OpInfoProvider>().elite;
    currentPotential = context.read<OpInfoProvider>().potential;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (currentElite != context.read<OpInfoProvider>().elite && localElite != null) {
      localElite = null;
    }
    if (currentPotential != context.read<OpInfoProvider>().potential && localPotential != null) {
      localPotential = null;
    }
  }

  void setLocalElite(int elite) {
    setState(() {
      localElite = elite;
    });
  }

  void setLocalPotential(int pot) {
    setState(() {
      localPotential = pot;
    });
  }

  @override
  Widget build(BuildContext context) {
    currentElite = context.select<OpInfoProvider, int>((p) => p.elite);
    currentPotential = context.select<OpInfoProvider, int>((p) => p.potential);

    int minElite = talentElites.lastWhere(
      (e) => e <= currentElite,
      orElse: () => talentElites.first,
    );

    int minPot = talentPots.lastWhere((e) => e <= currentPotential, orElse: () => talentPots.first);

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: List.generate(1 + widget.operator.talents.length, (index) {
          if (index == 0) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(talentElites.length, (index) {
                    return LilButton(
                      selected: talentElites[index] == (localElite ?? minElite),
                      fun: () => setLocalElite(talentElites[index]),
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
                      selected: talentPots[index] == (localPotential ?? minPot),
                      fun: () => setLocalPotential(talentPots[index]),
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
                return (localElite ?? minElite) >= thisTalentCandidateElite &&
                    (localPotential ?? minPot) >= thisTalentCandidatePot;
              },
              orElse: () => null,
            );

            if (candidate != null && candidate["isHideTalent"] == true) return null;

            bool unlocked = (candidate != null);

            final String? talentText = (candidate?["description"] as String?)?.akRichTextParser();

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
                        (widget.operator.talents[index - 1]["candidates"] as List).first["name"] ??
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
                              ? talentText ?? ''
                              : '<icon src="assets/sortIcon/lock.png"/> Unlocks at Elite $index',
                          tags: context.read<StyleProvider>().tagsAsArknights(context: context),
                          textAlign: TextAlign.start,
                          async: true,
                        ),
                      ),
                    ),

                    // extra slots
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // fck tomimi
                          if (candidate?["rangeId"] != null &&
                              (candidate?["blackboard"] as List).singleWhere(
                                    (e) => e?["key"] == "talent_override_rangeid_flag",
                                    orElse: () => null,
                                  )?["value"] ==
                                  1.0)
                            Expanded(child: RangeTile.smol(candidate?["rangeId"])),

                          //fck summoners
                          if (candidate?["tokenKey"] != null)
                            Expanded(
                              child: EntityCard(
                                entity: Entity.fromId(
                                  id: candidate!["tokenKey"],
                                  elite: localElite ?? currentElite,
                                  pot: localPotential ?? currentPotential,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }).nullParser(),
      ),
    );
  }
}
