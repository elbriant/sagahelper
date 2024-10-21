import 'package:flutter/material.dart';
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
}

Future<void> openUrl(String urlStr, {LaunchMode mode = LaunchMode.externalApplication}) async {
  final Uri uri = Uri.parse(urlStr);
  if (await canLaunchUrl(uri)){
    await launchUrl(uri, mode: mode);
  } else {
    throw Exception('Could not launch $uri');
  }
}

String githubEncode(String input) {
  return Uri.encodeFull(input).replaceAll('#', '%23');
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