// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:styled_text/styled_text.dart';

import 'package:sagahelper/components/popup_dialog.dart';
import 'package:sagahelper/core/static_colors.dart';
import 'package:sagahelper/models/styled_text_arknights_info_tag.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/context_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

final styleProvider = Provider<Style>((ref) {
  final brightness = ref.watch(contextProvider.select((p) => p.brightness));
  final gamedata = ref.watch(cacheProvider.select((p) => p.cachedGamedataConst));
  final currentTheme = ref.watch(configProvider.select((p) => p.customTheme));

  return Style(
    colors: StaticColors.fromBrightness(brightness),
    gamedata: gamedata,
    theme: currentTheme.fromBrightness(brightness),
  );
});

class Style {
  final Map<String, dynamic>? gamedata;
  final ThemeData theme;
  final StaticColors colors;

  Style({
    required this.gamedata,
    required this.colors,
    required this.theme,
  });

  Map<String, TextStyle> get richTextStyles => {
        "mission.levelname": const TextStyle(color: Color(0xFFFFDE00)),
        "mission.number": const TextStyle(color: Color(0xFFFFDE00)),
        "tu.kw": TextStyle(color: colors.akAttrUp),
        "tu.imp": const TextStyle(color: Color(0xFFFF0000)),
        "cc.vup": TextStyle(color: colors.akAttrUp),
        "cc.vdown": TextStyle(color: colors.akAttrDown),
        "cc.rem": const TextStyle(color: Color(0xFFF49800)),
        "cc.kw": TextStyle(color: colors.akKeyword),
        "cc.pn": const TextStyle(fontStyle: FontStyle.italic),
        "cc.talpu": const TextStyle(fontStyle: FontStyle.normal),
        "ba.vup": TextStyle(color: colors.akAttrUp),
        "ba.vdown": TextStyle(color: colors.akAttrDown),
        "ba.rem": const TextStyle(color: Color(0xFFF49800)),
        "ba.kw": TextStyle(color: colors.akKeyword),
        "ba.pn": const TextStyle(fontStyle: FontStyle.italic),
        "ba.talpu": TextStyle(color: colors.akAttrUp),
        "ba.xa": const TextStyle(color: Color(0xFFFF0000)),
        "ba.xb": const TextStyle(color: Color(0xFFFF7D00)),
        "ba.xc": const TextStyle(color: Color(0xFFFFFF00)),
        "ba.xd": const TextStyle(color: Color(0xFF00FF00)),
        "ba.xe": const TextStyle(color: Color(0xFF00FFFF)),
        "ba.xf": const TextStyle(color: Color(0xFF0291FF)),
        "ba.xg": const TextStyle(color: Color(0xFFFF00FF)),
        "eb.key": const TextStyle(color: Color(0xFF00FFFF)),
        "eb.danger": const TextStyle(color: Color(0xFFFF0000)),
        "ro.get": TextStyle(color: colors.akAttrUp),
        "ro.lose": const TextStyle(color: Color(0xFFC82A36)),
        "rolv.rem": const TextStyle(color: Color(0xFFFF4C22)),
        "lv.description": const TextStyle(color: Color(0xFFd8d769)),
        "lv.extrades": const TextStyle(color: Color(0xFFd8d769)),
        "lv.item": TextStyle(color: colors.orangeVariant),
        "lv.rem": TextStyle(color: colors.orangeVariant),
        "lv.fs": const TextStyle(color: Color(0xFFFF0000)),
        "lv.sp": const TextStyle(color: Color(0xFFfd4600)),
        "lv.ez": const TextStyle(color: Color(0xFF0098dc)),
        "crisisv2.nag": const TextStyle(color: Color(0xFFea9818)),
        "crisisv2.pos": const TextStyle(color: Color(0xFF16acaa)),
        "crisisv2.cra": const TextStyle(color: Color(0xFFd7181c)),
        "ro1.get": const TextStyle(color: Color(0xFFE5B684)),
        "ro2.lose": const TextStyle(color: Color(0xFFFF6E6E)),
        "ro2.get": const TextStyle(color: Color(0xFF59DDDC)),
        "ro2.virtue": const TextStyle(color: Color(0xFF0098dc)),
        "ro2.mutation": const TextStyle(color: Color(0xFF9266b2)),
        "ro2.desc": const TextStyle(color: Color(0xFF6d6d6d)),
        "ro3.lose": const TextStyle(color: Color(0xFFFF6E6E)),
        "ro3.get": const TextStyle(color: Color(0xFF9ed9fd)),
        "ro3.redt": const TextStyle(color: Color(0xFFff4532)),
        "ro3.greent": const TextStyle(color: Color(0xFF4ffaa5)),
        "ro3.bluet": const TextStyle(color: Color(0xFF0085ff)),
        "ro3.bosst": const TextStyle(color: Color(0xFFffffff)),
        "rc.title": TextStyle(color: colors.orangeVariant),
        "rc.subtitle": const TextStyle(color: Color(0xFFFFC90E)),
        "rc.em": const TextStyle(color: Color(0xFFFF7F27)),
        "rc.eml": const TextStyle(color: Color(0xFF32CD32)),
        "ga.title": TextStyle(color: colors.orangeVariant),
        "ga.subtitle": const TextStyle(color: Color(0xFFFFC90E)),
        "ga.up": const TextStyle(color: Color(0xFFFF7F27)),
        "ga.adgacha": const TextStyle(color: Color(0xFF00C8FF)),
        "ga.nbgacha": const TextStyle(color: Color(0xFF00DDBB)),
        "ga.limadgacha": const TextStyle(color: Color(0xFFFF7E1F)),
        "ga.percent": const TextStyle(color: Color(0xFFFFD800)),
        "ga.attention": const TextStyle(color: Color(0xFFFF3126)),
        "ga.classicgacha": const TextStyle(color: Color(0xFF00A8FF)),
        "attainga.desc": const TextStyle(color: Color(0xFFFF0000)),
        "attainga.desc2": const TextStyle(color: Color(0xFFFFD800)),
        "attainga.attention": const TextStyle(color: Color(0xFFE1322C)),
        "linkagega.charname": const TextStyle(color: Color(0xFFFFF6A9)),
        "linkagega.title": const TextStyle(color: Color(0xFFFF8A00)),
        "limtedga.title": TextStyle(color: colors.orangeVariant),
        "limtedga.subtitle": const TextStyle(color: Color(0xFFFFC90E)),
        "limtedga.up": const TextStyle(color: Color(0xFFFF7F27)),
        "limtedga.21": const TextStyle(color: Color(0xFFD7BCFF)),
        "limtedga.percent": const TextStyle(color: Color(0xFFFFD800)),
        "limtedga.attention": const TextStyle(color: Color(0xFFE1322C)),
        "limtedga.lattention": const TextStyle(color: Color(0xFFFF9E58)),
        "vc.newyear10": const TextStyle(color: Color(0xFFFF3823)),
        "vc.adgacha": TextStyle(color: colors.akAttrUp),
        "vc.attention": const TextStyle(color: Color(0xFFFFD800)),
        "act.missiontips": const TextStyle(color: Color(0xFFd9bd6a)),
        "lv.hdbg": const TextStyle(color: Color(0xFF7ba61f)),
        "tu.ht": const TextStyle(color: Color(0xFFff8d00)),
        "lv.act20side": const TextStyle(color: Color(0xFFF7BC44)),
        "lv.act20sre": const TextStyle(color: Color(0xFFF7BC44)),
        "lv.mhitem": const TextStyle(color: Color(0xFFA57F5B)),
        "lv.mhtx": const TextStyle(color: Color(0xFF1B1B1B)),
        "lv.mhfs": const TextStyle(color: Color(0xFFA57F5B)),
        "cc.miu": const TextStyle(color: Color(0xFF8F7156)),
        "ba.grt": const TextStyle(color: Color(0xFFFFAB27)),
        "ba.exl": const TextStyle(color: Color(0xFF14F0AF)),
        "ba.hrd": const TextStyle(color: Color(0xFFDA2536)),
        "act.spreward": const TextStyle(color: Color(0xFFFF5001)),
        "act.timelimit": const TextStyle(color: Color(0xFFffe300)),
        "vc.text": const TextStyle(color: Color(0xFF898989)),
        "vc.endtime": const TextStyle(color: Color(0xFFff0327)),
      };

  Map<String, TextStyle> get statsStyles => {
        'HP': TextStyle(
          color: colors.sHp,
        ),
        'ATK': TextStyle(
          color: colors.sAtk,
        ),
        'DPCost': TextStyle(
          color: colors.sCost,
        ),
        'Redeploy': TextStyle(
          color: colors.sRedeploy,
        ),
        'DEF': TextStyle(
          color: colors.sDef,
        ),
        'RES': TextStyle(
          color: colors.sRes,
        ),
        'Block': TextStyle(
          color: colors.sBlock,
        ),
        'ASPD': TextStyle(
          color: colors.sAspd,
        ),
        'ASPD%': TextStyle(
          color: colors.sAspdPercent,
        ),
      };

  final Map<String, StyledTextTagBase> tagsAsHtml = const {
    'b': StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
    'i': StyledTextTag(style: TextStyle(fontStyle: FontStyle.italic)),
  };

  Map<String, StyledTextTagBase> get tagsAsStats => {
        'color': StyledTextCustomTag(
          parse: (baseStyle, attrs) {
            return statsStyles[attrs['stat']];
          },
        ),
        'icon-HP': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/hp.png'),
            color: statsStyles['HP']!.color,
          ),
        ),
        'icon-ATK': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/atk.png'),
            color: statsStyles['ATK']!.color,
          ),
        ),
        'icon-DPCost': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/cost.png'),
            color: statsStyles['DPCost']!.color,
          ),
        ),
        'icon-Redeploy': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/redeploy.png'),
            color: statsStyles['Redeploy']!.color,
          ),
        ),
        'icon-DEF': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/def.png'),
            color: statsStyles['DEF']!.color,
          ),
        ),
        'icon-RES': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/res.png'),
            color: statsStyles['RES']!.color,
          ),
        ),
        'icon-Block': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/block.png'),
            color: statsStyles['Block']!.color,
          ),
        ),
        'icon-ASPD': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/atkspeed.png'),
            color: statsStyles['ASPD']!.color,
          ),
        ),
        'icon-ASPD%': StyledTextWidgetTag(
          ImageIcon(
            const AssetImage('assets/sortIcon/atkspeed.png'),
            color: statsStyles['ASPD%']!.color,
          ),
        ),
        'bonusCol': StyledTextTag(style: TextStyle(color: colors.sBonus)),
      };

  Map<String, StyledTextTagBase> get tagsAsArknights => {
        'b': const StyledTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
        'i': const StyledTextTag(style: TextStyle(fontStyle: FontStyle.italic)),
        'i-sub': StyledTextTag(
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        'color': StyledTextCustomTag(
          baseStyle: const TextStyle(fontStyle: FontStyle.normal),
          parse: (baseStyle, attributes) {
            if (attributes.containsKey('name') &&
                (attributes['name']!.substring(0, 1) == '#') &&
                attributes['name']!.length >= 6) {
              final String hexColor = attributes['name']!.substring(1);
              if (hexColor.toLowerCase() != 'ffffff' && hexColor.toLowerCase() != 'ffffffff') {
                final String alphaChannel =
                    (hexColor.length == 8) ? hexColor.substring(6, 8) : 'FF';
                final Color color = Color(
                  int.parse('0x$alphaChannel${hexColor.substring(0, 6)}'),
                );
                return baseStyle!.copyWith(color: color);
              } else {
                return baseStyle!.copyWith(
                  color: theme.colorScheme.secondary,
                );
              }
            } else {
              return baseStyle;
            }
          },
        ),
        'info': StyledTextCustomTag(
          baseStyle: const TextStyle(fontStyle: FontStyle.normal),
          parse: (baseStyle, attributes) {
            if (attributes.containsKey('custom')) {
              final String richtext = attributes['custom']!;
              final TextStyle customStyle = richTextStyles[richtext] ?? baseStyle!;
              return baseStyle?.copyWith(
                color: customStyle.color ?? baseStyle.color,
                fontStyle: customStyle.fontStyle ?? baseStyle.fontStyle,
              );
            } else {
              return baseStyle;
            }
          },
        ),
        'selectable': StyledTextActionTag(
          (String? text, Map<String?, String?> attrs) {
            dev.log('selected ${attrs.toString()}');

            if (gamedata == null) return;

            if (!(gamedata!["termDescriptionDict"] as Map).containsKey(attrs['custom'])) return;

            final termDict = (gamedata!["termDescriptionDict"] as Map)[attrs['custom']] as Map;

            openDictionaryPopup(termDict);
          },
          style: const TextStyle(decoration: TextDecoration.underline),
        ),
        'icon': StyledTextWidgetBuilderTag((context, attributes, textContent) {
          assert(attributes['src'] != null);
          final String iconPath = attributes['src']!;
          return ImageIcon(
            AssetImage(iconPath),
            color: Theme.of(context).textTheme.bodyMedium?.color,
          );
        }),
        'diffInsert': StyledTextTag(
          style: TextStyle(
            color: colors.sBonusText,
          ),
        ),
        'add-icon': StyledTextIconTag(
          Icons.add,
          color: colors.sBonus,
        ),
        'info-v2': StyledTextArknightsInfoTag(
          baseStyle: const TextStyle(fontStyle: FontStyle.normal),
          parse: (baseStyle, attributes) {
            if (attributes.containsKey('custom') && !attributes.containsKey('selectable')) {
              final String richtext = attributes['custom']!;
              final TextStyle customStyle = richTextStyles[richtext] ?? baseStyle!;
              return baseStyle?.copyWith(
                color: customStyle.color ?? baseStyle.color,
                fontStyle: customStyle.fontStyle ?? baseStyle.fontStyle,
              );
            } else if (attributes.containsKey('selectable')) {
              return const TextStyle(decoration: TextDecoration.underline);
            } else {
              return baseStyle;
            }
          },
          onTapGenerator: (_, attrs_) {
            if (!attrs_.containsKey('selectable')) return null;

            return (String? text, Map<String?, String?> attrs) {
              dev.log('selected ${attrs.toString()}');

              if (gamedata == null) return;

              if (!(gamedata!["termDescriptionDict"] as Map).containsKey(attrs['custom'])) {
                return;
              }

              final termDict = (gamedata!["termDescriptionDict"] as Map)[attrs['custom']] as Map;

              openDictionaryPopup(termDict);
            };
          },
        ),
      };

  void openDictionaryPopup(Map termDict) {
    PopupDialog.dictionary(
      term: Text(termDict["termName"]),
      definition: StyledText(
        text: (termDict["description"] as String).akRichTextParser(),
        tags: tagsAsArknights,
        async: true,
      ),
    );
  }
}
