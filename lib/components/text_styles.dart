import 'package:flutter/material.dart';
import 'package:sagahelper/global_data.dart';
import 'package:styled_text/styled_text.dart';

Map<String, TextStyle> richTextStyles = {
  "mission.levelname": TextStyle(color: Color(0xFFFFDE00)),
  "mission.number": TextStyle(color: Color(0xFFFFDE00)),
  "tu.kw": TextStyle(color: Color(0xFF0098DC)),
  "tu.imp": TextStyle(color: Color(0xFFFF0000)),
  "cc.vup": TextStyle(color: Color(0xFF0098DC)),
  "cc.vdown": TextStyle(color: Color(0xFFFF6237)),
  "cc.rem": TextStyle(color: Color(0xFFF49800)),
  "cc.kw": TextStyle(color: Color(0xFF00B0FF)),
  "cc.pn": TextStyle(fontStyle: FontStyle.italic),
  "cc.talpu": TextStyle(fontStyle: FontStyle.normal),
  "ba.vup": TextStyle(color: Color(0xFF0098DC)),
  "ba.vdown": TextStyle(color: Color(0xFFFF6237)),
  "ba.rem": TextStyle(color: Color(0xFFF49800)),
  "ba.kw": TextStyle(color: Color(0xFF00B0FF)),
  "ba.pn": TextStyle(fontStyle: FontStyle.italic),
  "ba.talpu": TextStyle(color: Color(0xFF0098DC)),
  "ba.xa": TextStyle(color: Color(0xFFFF0000)),
  "ba.xb": TextStyle(color: Color(0xFFFF7D00)),
  "ba.xc": TextStyle(color: Color(0xFFFFFF00)),
  "ba.xd": TextStyle(color: Color(0xFF00FF00)),
  "ba.xe": TextStyle(color: Color(0xFF00FFFF)),
  "ba.xf": TextStyle(color: Color(0xFF0291FF)),
  "ba.xg": TextStyle(color: Color(0xFFFF00FF)),
  "eb.key": TextStyle(color: Color(0xFF00FFFF)),
  "eb.danger": TextStyle(color: Color(0xFFFF0000)),
  "ro.get": TextStyle(color: Color(0xFF0098DC)),
  "ro.lose": TextStyle(color: Color(0xFFC82A36)),
  "rolv.rem": TextStyle(color: Color(0xFFFF4C22)),
  "lv.description": TextStyle(color: Color(0xFFd8d769)),
  "lv.extrades": TextStyle(color: Color(0xFFd8d769)),
  "lv.item": TextStyle(color: Color(0xFFFFFFFF)),
  "lv.rem": TextStyle(color: Color(0xFFFFFFFF)),
  "lv.fs": TextStyle(color: Color(0xFFFF0000)),
  "lv.sp": TextStyle(color: Color(0xFFfd4600)),
  "lv.ez": TextStyle(color: Color(0xFF0098dc)),
  "crisisv2.nag": TextStyle(color: Color(0xFFea9818)),
  "crisisv2.pos": TextStyle(color: Color(0xFF16acaa)),
  "crisisv2.cra": TextStyle(color: Color(0xFFd7181c)),
  "ro1.get": TextStyle(color: Color(0xFFE5B684)),
  "ro2.lose": TextStyle(color: Color(0xFFFF6E6E)),
  "ro2.get": TextStyle(color: Color(0xFF59DDDC)),
  "ro2.virtue": TextStyle(color: Color(0xFF0098dc)),
  "ro2.mutation": TextStyle(color: Color(0xFF9266b2)),
  "ro2.desc": TextStyle(color: Color(0xFF6d6d6d)),
  "ro3.lose": TextStyle(color: Color(0xFFFF6E6E)),
  "ro3.get": TextStyle(color: Color(0xFF9ed9fd)),
  "ro3.redt": TextStyle(color: Color(0xFFff4532)),
  "ro3.greent": TextStyle(color: Color(0xFF4ffaa5)),
  "ro3.bluet": TextStyle(color: Color(0xFF0085ff)),
  "ro3.bosst": TextStyle(color: Color(0xFFffffff)),
  "rc.title": TextStyle(color: Color(0xFFFFFFFF)),
  "rc.subtitle": TextStyle(color: Color(0xFFFFC90E)),
  "rc.em": TextStyle(color: Color(0xFFFF7F27)),
  "rc.eml": TextStyle(color: Color(0xFF32CD32)),
  "ga.title": TextStyle(color: Color(0xFFFFFFFF)),
  "ga.subtitle": TextStyle(color: Color(0xFFFFC90E)),
  "ga.up": TextStyle(color: Color(0xFFFF7F27)),
  "ga.adgacha": TextStyle(color: Color(0xFF00C8FF)),
  "ga.nbgacha": TextStyle(color: Color(0xFF00DDBB)),
  "ga.limadgacha": TextStyle(color: Color(0xFFFF7E1F)),
  "ga.percent": TextStyle(color: Color(0xFFFFD800)),
  "ga.attention": TextStyle(color: Color(0xFFFF3126)),
  "ga.classicgacha": TextStyle(color: Color(0xFF00A8FF)),
  "attainga.desc": TextStyle(color: Color(0xFFFF0000)),
  "attainga.desc2": TextStyle(color: Color(0xFFFFD800)),
  "attainga.attention": TextStyle(color: Color(0xFFE1322C)),
  "linkagega.charname": TextStyle(color: Color(0xFFFFF6A9)),
  "linkagega.title": TextStyle(color: Color(0xFFFF8A00)),
  "limtedga.title": TextStyle(color: Color(0xFFFFFFFF)),
  "limtedga.subtitle": TextStyle(color: Color(0xFFFFC90E)),
  "limtedga.up": TextStyle(color: Color(0xFFFF7F27)),
  "limtedga.21": TextStyle(color: Color(0xFFD7BCFF)),
  "limtedga.percent": TextStyle(color: Color(0xFFFFD800)),
  "limtedga.attention": TextStyle(color: Color(0xFFE1322C)),
  "limtedga.lattention": TextStyle(color: Color(0xFFFF9E58)),
  "vc.newyear10": TextStyle(color: Color(0xFFFF3823)),
  "vc.adgacha": TextStyle(color: Color(0xFF0098DC)),
  "vc.attention": TextStyle(color: Color(0xFFFFD800)),
  "act.missiontips": TextStyle(color: Color(0xFFd9bd6a)),
  "lv.hdbg": TextStyle(color: Color(0xFF7ba61f)),
  "tu.ht": TextStyle(color: Color(0xFFff8d00)),
  "lv.act20side": TextStyle(color: Color(0xFFF7BC44)),
  "lv.act20sre": TextStyle(color: Color(0xFFF7BC44)),
  "lv.mhitem": TextStyle(color: Color(0xFFA57F5B)),
  "lv.mhtx": TextStyle(color: Color(0xFF1B1B1B)),
  "lv.mhfs": TextStyle(color: Color(0xFFA57F5B)),
  "cc.miu": TextStyle(color: Color(0xFF8F7156)),
  "ba.grt": TextStyle(color: Color(0xFFFFAB27)),
  "ba.exl": TextStyle(color: Color(0xFF14F0AF)),
  "ba.hrd": TextStyle(color: Color(0xFFDA2536)),
  "act.spreward": TextStyle(color: Color(0xFFFF5001)),
  "act.timelimit": TextStyle(color: Color(0xFFffe300)),
  "vc.text": TextStyle(color: Color(0xFF898989)),
  "vc.endtime": TextStyle(color: Color(0xFFff0327))
};

Map<String, StyledTextTagBase> tagsAsHtml = {
  'b' : StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
  'i' : StyledTextTag(style: TextStyle(fontStyle: FontStyle.italic))
};

Map<String, StyledTextTagBase> tagsAsArknights = {
  'b' : StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
  'i' : StyledTextTag(style: TextStyle(fontStyle: FontStyle.italic)),
  'color': StyledTextCustomTag(
    baseStyle: TextStyle(fontStyle: FontStyle.normal),
    parse: (baseStyle, attributes) {
      if (attributes.containsKey('name') && (attributes['name']!.substring(0, 1) == '#') && attributes['name']!.length >= 6) {
        final String hexColor = attributes['name']!.substring(1);
        if (hexColor.toLowerCase() != 'ffffff' && hexColor.toLowerCase() != 'ffffffff') {
          final String alphaChannel = (hexColor.length == 8) ? hexColor.substring(6, 8) : 'FF';
          final Color color = Color(int.parse('0x$alphaChannel${hexColor.substring(0, 6)}'));
          return baseStyle!.copyWith(color: color);
        } else {
          return baseStyle!.copyWith(color: Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.secondary);
        }
      } else {
        return baseStyle;
      }
    }
  ),
  'info' : StyledTextCustomTag(
    baseStyle: TextStyle(fontStyle: FontStyle.normal),
    parse: (baseStyle, attributes) {
      if (attributes.containsKey('custom')) {
        final String richtext = attributes['custom']!;
        final TextStyle customStyle = richTextStyles[richtext] ?? baseStyle!;
        return baseStyle!.copyWith(
          color: customStyle.color ?? baseStyle.color,
          fontStyle: customStyle.fontStyle ?? baseStyle.fontStyle
        );
      } else {
        return baseStyle;
      }
    }
  ),
  'selectable' : StyledTextWidgetBuilderTag (
    (BuildContext context, Map<String?, String?> attributes, String? textContent) {
      return GestureDetector(
        onTap: (){
          // TODO open dict
        },
        child: Text(textContent ?? '', style: TextStyle(decoration: TextDecoration.underline))
      );
    },
  ),
};
// input example <@ba.vup>{cost}</> where
