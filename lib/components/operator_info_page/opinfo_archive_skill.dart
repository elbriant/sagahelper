import 'package:provider/provider.dart';
import 'package:sagahelper/components/big_title_text.dart';
import 'package:sagahelper/components/operator_info_page/operator_base_skill.dart';
import 'package:sagahelper/components/operator_info_page/operator_modules.dart';
import 'package:sagahelper/components/operator_info_page/operator_skill.dart';
import 'package:sagahelper/components/operator_info_page/operator_stats.dart';
import 'package:sagahelper/components/operator_info_page/operator_talents.dart';
import 'package:sagahelper/components/trait_card.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/op_info_provider.dart';
import 'package:flutter/material.dart';

class OpinfoArchiveSkill extends StatelessWidget {
  const OpinfoArchiveSkill(this.operator, {super.key});
  final Operator operator;

  @override
  Widget build(BuildContext context) {
    final elite = operator.phases.length - 1;
    final maxLv = (operator.phases[elite]["maxLevel"] as int).toDouble();

    return ChangeNotifierProvider(
      create: (_) => OpInfoProvider(
        elite: elite,
        maxLevel: maxLv,
        level: maxLv,
      ),
      builder: (context, child) {
        // maybe hold tap on elite, skill and mod to show cost material
        // do a tip show to say this ||
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BigTitleText(title: 'Trait'),
              TraitCard(
                operator: operator,
              ),
              const Divider(),
              const BigTitleText(title: 'Stats'),
              OperatorStats(
                operator: operator,
              ),
              const Divider(),
              const BigTitleText(title: 'Talents'),
              OperatorTalents(
                operator: operator,
              ),
              const Divider(),
              if (operator.skills.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BigTitleText(title: 'Skills'),
                    OperatorSkill(
                      operator: operator,
                    ),
                    const Divider(),
                  ],
                ),
              if (operator.modules != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BigTitleText(title: 'Modules'),
                    OperatorModules(
                      operator: operator,
                    ),
                    const Divider(),
                  ],
                ),
              if (operator.baseSkills.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BigTitleText(title: 'RIIC Base Skills'),
                    OperatorBaseSkill(
                      operator: operator,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
