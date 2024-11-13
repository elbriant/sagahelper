import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Original character  Escaped character
// ------------------  -----------------
// "                   &quot;
// '                   &apos;
// &                   &amp;
// <                   &lt;
// >                   &gt;
// <space>             &space;

const Map<String, String> escapeRules = {
  '<Substitute>' : '&lt;Substitute&gt;'
};

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
  String akRichTextParser() {
    String escapedString = this;

    for (String rule in escapeRules.keys) {
      escapedString = escapedString.replaceAll(RegExp(rule), escapeRules[rule]!);
    }
    
    return escapedString.replaceAll(RegExp(r'<@'), '<info custom=').replaceAll(RegExp(r'<\$'), '<selectable custom=');
  }
  String varParser(List<dynamic>? vars) {
    if (vars == null) return this;

    // blackboard
    String parsed = this;
    for (Map map in vars) {
      if (map['valueStr'] == null) {
        parsed = parsed.replaceAll(RegExp('{${map['key']}}'), (map['value'] as double).round().toString()).replaceAll(RegExp('{${map['key']}:0%}'), '${((map['value'] as double) * 100).round().toString()}%');
      } else {
        parsed = parsed.replaceAll(RegExp('{${map['key']}}'), map['value']);
      }
    }

    return parsed;
  }
  String nicknameParser() {
    final nick = NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().nickname;
    if (nick != null) {
      return replaceAll('{@nickname}', nick);
    } else {
      return replaceAll('Dr. {@nickname}', 'Doctor').replaceAll('Dr.{@nickname}', 'Doctor').replaceAll('{@nickname}', 'Doctor');
    }
  }
  String githubEncode() {
    return Uri.encodeFull(this).replaceAll('#', '%23');
  }
}

Future<void> openUrl(String urlStr, {LaunchMode mode = LaunchMode.externalApplication}) async {
  final Uri uri = Uri.parse(urlStr);
  if (await canLaunchUrl(uri)){
    await launchUrl(uri, mode: mode);
  } else {
    throw Exception('Could not launch $uri');
  }
}



extension ListExtension on List<Widget?> {
  List<Widget> nullParser() {
    List<Widget> listed = [];
    for (var item in this) {
      if (item != null) listed.add(item);
    }
    return listed;
  }
}