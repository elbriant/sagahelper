import 'package:flutter/material.dart';

class OpInfoProvider with ChangeNotifier {
  OpInfoProvider({
    required this.level,
    required this.maxLevel,
    required this.elite,
  });

  double level;
  void setLevel(double value) {
    level = value;
    notifyListeners();
  }

  double maxLevel;
  void setMaxLevel(double value) {
    maxLevel = value;
    notifyListeners();
  }

  int elite;
  void setElite(int value, double maxLevel) {
    elite = value;
    maxLevel = maxLevel;
    level = level.clamp(1.0, maxLevel);

    notifyListeners();
  }

  // skills
  int selectedSkill = 0;
  void setSelectedSkill(int value) {
    selectedSkill = value;
    notifyListeners();
  }

  int skillLevel = 0;
  void setSkillLevel(int value) {
    skillLevel = value;
    notifyListeners();
  }

  // mod
  Map<String, double> modAttrBuffs = {};
  void setModAttrBuffs(Map<String, double> value) {
    modAttrBuffs = Map.of(value);
    notifyListeners();
  }

  //pot
  int potential = 0;
  void setPotential(int value) {
    potential = value;
    notifyListeners();
  }
}
