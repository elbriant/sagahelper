import 'package:flutter/material.dart';

@immutable
class OperatorContext {
  final double level;
  final double maxLevel;
  final int elite;
  final int selectedSkill;
  final int skillLevel;
  final int potential;
  final Map<String, double> modAttrBuffs;

  const OperatorContext({
    required this.level,
    required this.maxLevel,
    required this.elite,
    this.selectedSkill = 0,
    this.skillLevel = 0,
    this.potential = 0,
    this.modAttrBuffs = const {},
  });

  OperatorContext copyWith({
    double? level,
    double? maxLevel,
    int? elite,
    int? selectedSkill,
    int? skillLevel,
    int? potential,
    Map<String, double>? modAttrBuffs,
  }) {
    return OperatorContext(
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      elite: elite ?? this.elite,
      selectedSkill: selectedSkill ?? this.selectedSkill,
      skillLevel: skillLevel ?? this.skillLevel,
      potential: potential ?? this.potential,
      modAttrBuffs: modAttrBuffs ?? this.modAttrBuffs,
    );
  }
}
