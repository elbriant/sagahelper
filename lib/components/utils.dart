import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
  String akRichTextParser() {
    return replaceAll(RegExp(r'<@'), '<info custom=').replaceAll(RegExp(r'<\$'), '<selectable custom=');
  }
  String varParser(Map vars) {
    String parsed = this;
    for (String key in vars.keys) {
      parsed = parsed.replaceAll(RegExp('{$key}'), vars[key].toString());
    }
    return parsed;
  }
  String nicknameParser() {
    final nick = NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().nickname;
    if (nick != null) {
      return replaceAll('{@nickname}', nick);
    } else {
      String first = replaceAll('Dr. {@nickname}', 'Doctor');
      return first.replaceAll('Dr.{@nickname}', 'Doctor');
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