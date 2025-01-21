import 'package:flutter/material.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/models/operator.dart';

class PotentialsTile extends StatelessWidget {
  const PotentialsTile({
    super.key,
    required this.operator,
    required this.currentPot,
    required this.potSetter,
  });

  final Operator operator;
  final int currentPot;

  final ValueSetter<int> potSetter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(operator.potentials.length, (index) {
        return LilButton(
          selected: index <= currentPot - 1,
          icon: Row(
            children: [
              Image.asset(
                'assets/pot/potential_${index + 1}_small.png',
                scale: 1.6,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  operator.potentials[index]["description"],
                  textScaler: const TextScaler.linear(0.7),
                ),
              ),
            ],
          ),
          fun: () => potSetter.call(index),
        );
      }),
    );
  }
}
