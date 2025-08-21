// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opInfoProvider = NotifierProvider.autoDispose<OpInfoNotifier, OpInfo>(OpInfoNotifier.new);

// TODO: may create a future provider based on op info to get color Theme original
// based on image

@immutable
class OpInfo {
  final double level;
  final double maxLevel;
  final int elite;
  final int selectedSkill;
  final int skillLevel;
  final int potential;
  final Map<String, double> modAttrBuffs;

  const OpInfo({
    required this.level,
    required this.maxLevel,
    required this.elite,
    this.selectedSkill = 0,
    this.skillLevel = 0,
    this.potential = 0,
    this.modAttrBuffs = const {},
  });

  OpInfo copyWith({
    double? level,
    double? maxLevel,
    int? elite,
    int? selectedSkill,
    int? skillLevel,
    int? potential,
    Map<String, double>? modAttrBuffs,
  }) {
    return OpInfo(
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

class OpInfoNotifier extends Notifier<OpInfo> {
  @override
  OpInfo build() {
    throw UnimplementedError('Must override and give entity info');
  }

  void setElite(int value, double maxLevel) {
    state = state.copyWith(
      elite: value,
      maxLevel: maxLevel,
      level: state.level.clamp(1.0, maxLevel),
    );
  }

  void setModAttrBuffs(Map<String, double> value) {
    state = state.copyWith(
      modAttrBuffs: value,
    );
  }
}
