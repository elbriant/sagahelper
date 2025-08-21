import 'package:flutter/material.dart';

class StaticColors {
  //normal colors
  final Color green;
  final Color onGreen;
  final Color greenVariant;
  final Color onGreenVariant;
  final Color blue;
  final Color onBlue;
  final Color blueVariant;
  final Color onBlueVariant;
  final Color yellow;
  final Color onYellow;
  final Color yellowVariant;
  final Color onYellowVariant;
  final Color red;
  final Color onRed;
  final Color redVariant;
  final Color onRedVariant;
  final Color orange;
  final Color onOrange;
  final Color orangeVariant;
  final Color onOrangeVariant;

  //stat colors
  final Color sHp;
  final Color sAtk;
  final Color sRedeploy;
  final Color sBlock;
  final Color sDef;
  final Color sRes;
  final Color sCost;
  final Color sAspd;
  final Color sAspdPercent;

  final Color sBonus;
  final Color sBonusText;

  //ak colors
  final Color akAttrUp;
  final Color akAttrDown;
  final Color akKeyword;

  const StaticColors({
    required this.greenVariant,
    required this.onGreenVariant,
    required this.blueVariant,
    required this.onBlueVariant,
    required this.yellowVariant,
    required this.onYellowVariant,
    required this.redVariant,
    required this.onRedVariant,
    required this.orangeVariant,
    required this.onOrangeVariant,
    required this.green,
    required this.onGreen,
    required this.blue,
    required this.onBlue,
    required this.yellow,
    required this.onYellow,
    required this.red,
    required this.onRed,
    required this.orange,
    required this.onOrange,
    required this.sHp,
    required this.sAtk,
    required this.sRedeploy,
    required this.sBlock,
    required this.sDef,
    required this.sRes,
    required this.sCost,
    required this.sAspd,
    required this.sAspdPercent,
    required this.sBonus,
    required this.sBonusText,
    required this.akAttrUp,
    required this.akAttrDown,
    required this.akKeyword,
  });

  factory StaticColors.light() {
    return StaticColors(
      green: const HSLColor.fromAHSL(1.0, 115.0, 1.0, 0.25).toColor(),
      onGreen: const HSLColor.fromAHSL(1.0, 115.0, 1.0, 0.85).toColor(),
      greenVariant: const HSLColor.fromAHSL(1.0, 115.0, 0.6, 0.47).toColor(),
      onGreenVariant: const HSLColor.fromAHSL(1.0, 115.0, 0.95, 0.1).toColor(),
      blue: const HSLColor.fromAHSL(1.0, 205.0, 1.0, 0.75).toColor(),
      onBlue: const HSLColor.fromAHSL(1.0, 205.0, 1.0, 0.15).toColor(),
      blueVariant: const HSLColor.fromAHSL(1.0, 205.0, 0.6, 0.4).toColor(),
      onBlueVariant: const HSLColor.fromAHSL(1.0, 205.0, 1.0, 0.9).toColor(),
      yellow: const HSLColor.fromAHSL(1.0, 55.0, 1.0, 0.35).toColor(),
      onYellow: const HSLColor.fromAHSL(1.0, 55.0, 1.0, 0.85).toColor(),
      yellowVariant: const HSLColor.fromAHSL(1.0, 55.0, 1.0, 0.5).toColor(),
      onYellowVariant: const HSLColor.fromAHSL(1.0, 55.0, 0.95, 0.1).toColor(),
      red: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.25).toColor(),
      onRed: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.85).toColor(),
      redVariant: const HSLColor.fromAHSL(1.0, 0.0, 0.6, 0.47).toColor(),
      onRedVariant: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.90).toColor(),
      orange: const HSLColor.fromAHSL(1.0, 22.0, 1.0, 0.35).toColor(),
      onOrange: const HSLColor.fromAHSL(1.0, 22.0, 1.0, 0.85).toColor(),
      orangeVariant: const HSLColor.fromAHSL(1.0, 22.0, 0.6, 0.47).toColor(),
      onOrangeVariant: const HSLColor.fromAHSL(1.0, 22.0, 0.95, 0.1).toColor(),
      sHp: const HSLColor.fromAHSL(1.0, 115.0, 1.0, 0.37).toColor(),
      sAtk: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.4).toColor(),
      sRedeploy: const HSLColor.fromAHSL(1.0, 320.0, 1.0, 0.4).toColor(),
      sDef: const HSLColor.fromAHSL(1.0, 200.0, 1.0, 0.45).toColor(),
      sCost: const HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.65).toColor(),
      sAspd: const HSLColor.fromAHSL(1.0, 50.0, 1.0, 0.45).toColor(),
      sAspdPercent: const HSLColor.fromAHSL(1.0, 50.0, 1.0, 0.35).toColor(),
      sRes: const HSLColor.fromAHSL(1.0, 270.0, 1.0, 0.4).toColor(),
      sBlock: const HSLColor.fromAHSL(1.0, 265.0, 0.30, 0.45).toColor(),
      sBonus: const HSLColor.fromAHSL(1.0, 115.0, 0.7, 0.35).toColor(),
      sBonusText: const HSLColor.fromAHSL(1.0, 115.0, 0.7, 0.3).toColor(),
      akAttrUp: const HSLColor.fromAHSL(1.0, 199.0, 1, 0.4).toColor(),
      akAttrDown: const HSLColor.fromAHSL(1.0, 13.0, 1, 0.57).toColor(),
      akKeyword: const HSLColor.fromAHSL(1.0, 199.0, 1, 0.45).toColor(),
    );
  }

  factory StaticColors.dark() {
    return StaticColors(
      green: const HSLColor.fromAHSL(1.0, 115.0, 1.0, 0.75).toColor(),
      onGreen: const HSLColor.fromAHSL(1.0, 115.0, 1.0, 0.15).toColor(),
      greenVariant: const HSLColor.fromAHSL(1.0, 115.0, 0.6, 0.4).toColor(),
      onGreenVariant: const HSLColor.fromAHSL(1.0, 115.0, 0.95, 0.1).toColor(),
      blue: const HSLColor.fromAHSL(1.0, 205.0, 1.0, 0.75).toColor(),
      onBlue: const HSLColor.fromAHSL(1.0, 205.0, 1.0, 0.15).toColor(),
      blueVariant: const HSLColor.fromAHSL(1.0, 205.0, 0.6, 0.4).toColor(),
      onBlueVariant: const HSLColor.fromAHSL(1.0, 205.0, 1.0, 0.9).toColor(),
      yellow: const HSLColor.fromAHSL(1.0, 55.0, 1.0, 0.55).toColor(),
      onYellow: const HSLColor.fromAHSL(1.0, 55.0, 1.0, 0.15).toColor(),
      yellowVariant: const HSLColor.fromAHSL(1.0, 55.0, 1.0, 0.32).toColor(),
      onYellowVariant: const HSLColor.fromAHSL(1.0, 55.0, 0.95, 0.1).toColor(),
      red: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.75).toColor(),
      onRed: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.15).toColor(),
      redVariant: const HSLColor.fromAHSL(1.0, 0.0, 0.6, 0.4).toColor(),
      onRedVariant: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.90).toColor(),
      orange: const HSLColor.fromAHSL(1.0, 22.0, 1.0, 0.65).toColor(),
      onOrange: const HSLColor.fromAHSL(1.0, 22.0, 1.0, 0.15).toColor(),
      orangeVariant: const HSLColor.fromAHSL(1.0, 22.0, 0.6, 0.4).toColor(),
      onOrangeVariant: const HSLColor.fromAHSL(1.0, 22.0, 0.95, 0.1).toColor(),
      sHp: const HSLColor.fromAHSL(1.0, 115.0, 1.0, 0.55).toColor(),
      sAtk: const HSLColor.fromAHSL(1.0, 0.0, 1.0, 0.55).toColor(),
      sRedeploy: const HSLColor.fromAHSL(1.0, 320.0, 1.0, 0.55).toColor(),
      sDef: const HSLColor.fromAHSL(1.0, 200.0, 1.0, 0.55).toColor(),
      sCost: const HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.85).toColor(),
      sAspd: const HSLColor.fromAHSL(1.0, 50.0, 1.0, 0.65).toColor(),
      sAspdPercent: const HSLColor.fromAHSL(1.0, 50.0, 1.0, 0.5).toColor(),
      sRes: const HSLColor.fromAHSL(1.0, 270.0, 1.0, 0.55).toColor(),
      sBlock: const HSLColor.fromAHSL(1.0, 265.0, 0.30, 0.55).toColor(),
      sBonus: const HSLColor.fromAHSL(1.0, 115.0, 0.7, 0.55).toColor(),
      sBonusText: const HSLColor.fromAHSL(1.0, 115.0, 0.7, 0.45).toColor(),
      akAttrUp: const HSLColor.fromAHSL(1.0, 199.0, 1, 0.43).toColor(),
      akAttrDown: const HSLColor.fromAHSL(1.0, 13.0, 1, 0.61).toColor(),
      akKeyword: const HSLColor.fromAHSL(1.0, 199.0, 1, 0.50).toColor(),
    );
  }

  factory StaticColors.fromBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      return StaticColors.light();
    } else {
      return StaticColors.dark();
    }
  }
}
