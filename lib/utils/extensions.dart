import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/settings_provider.dart';

// Original character  Escaped character
// ------------------  -----------------
// "                   &quot;
// '                   &apos;
// &                   &amp;
// <                   &lt;
// >                   &gt;
// <space>             &space;

const Map<String, String> escapeRules = {
  '<Substitute>': '&lt;Substitute&gt;',
  '<Support Devices>': '&lt;Support Devices&gt;',
};

extension ListExtension on List<Widget?> {
  List<Widget> nullParser() {
    List<Widget> listed = [];
    for (var item in this) {
      if (item != null) listed.add(item);
    }
    return listed;
  }
}

extension DoubleExtension on double {
  /// makes a String of a double value
  /// removing leading zeros
  String toStringWithPrecision([int? precision]) {
    return toStringAsFixed(precision ?? 3).replaceFirst(RegExp(r'\.?0*$'), '');
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String akRichTextParser() {
    String escapedString = this;

    for (String rule in escapeRules.keys) {
      escapedString = escapedString.replaceAll(RegExp(rule), escapeRules[rule]!);
    }

    // escape stage hazards
    escapedString = escapedString.replaceAllMapped(
      RegExp(r'(?<=<@lv\.item>)<([\w\s-]+)>(?=<\/>)'),
      (m) => '&lt;${m[1]}&gt;',
    );

    return escapedString
        .replaceAll(RegExp(r'<@'), '<info-v2 custom=')
        .replaceAll(RegExp(r'<\$'), '<info-v2 selectable="true" custom=')
        .replaceAll(RegExp(r'(?<!/)>'), '>')
        .replaceAll(RegExp(r'<\/>'), '</info-v2>');
  }

  String varParser(List<dynamic>? vars) {
    if (vars == null) return this;

    // blackboard
    String parsed = this;
    for (Map map in vars) {
      if (map['valueStr'] == null) {
        parsed = parsed
            .replaceAll(
              RegExp('(-)?{(-)?${RegExp.escape(map['key'])}(:0)?(.0)?}', caseSensitive: false),
              (map['value'] as double).toStringWithPrecision(),
            )
            .replaceAll(
              RegExp(
                '{${RegExp.escape(map['key'])}:0(.0)?%}',
                caseSensitive: false,
              ),
              '${((map['value'] as double) * 100).toStringWithPrecision()}%',
            )
            .replaceAll(
              RegExp(
                '{-${RegExp.escape(map['key'])}:0(.0)?%}',
                caseSensitive: false,
              ),
              '${((map['value'] as double) * 100 * -1).toStringWithPrecision()}%',
            );
      } else {
        parsed = parsed.replaceAll(
          RegExp('{${RegExp.escape(map['key'])}}', caseSensitive: false),
          map['value'],
        );
      }
    }

    return parsed;
  }

  String nicknameParser() {
    final nick = NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().nickname;
    if (nick != null) {
      return replaceAll('{@nickname}', nick);
    } else {
      return replaceAll(RegExp(r'(Dr.)?(\s)?{@nickname}'), 'Doctor');
    }
  }

  String githubEncode() {
    return Uri.encodeFull(this).replaceAll('#', '%23');
  }

  Color parseAsHex() {
    assert(length >= 6 && length <= 9);

    String hexColor = this;

    if (startsWith('#')) hexColor = substring(1);

    final String alphaChannel = (hexColor.length == 8) ? hexColor.substring(6, 8) : 'FF';

    final Color color = Color(
      int.parse('0x$alphaChannel${hexColor.substring(0, 6)}'),
    );

    return color;
  }
}

extension DateTimeExtension on DateTime {
  String formatHome() {
    List<String> result = [];
    final settings = NavigationService.navigatorKey.currentContext!.read<SettingsProvider>();

    // date
    if (settings.homeShowDate) {
      result.add('EEE dd/MM');
    }

    //time
    if (settings.homeHour12Format) {
      if (settings.homeShowSeconds) {
        //12 hour and seconds
        result.add('hh:mm:ss a');
      } else {
        //12 hour
        result.add('h:mm a');
      }
    } else {
      if (settings.homeShowSeconds) {
        //24 hour and seconds
        result.add('HH:mm:ss');
      } else {
        //24 hour
        result.add('H:mm');
      }
    }
    return DateFormat(result.join(' ')).format(this);
  }
}

extension DurationExtension on Duration {
  String asRemainingTime() {
    List<String> result = [];

    //days
    if (inDays > 1) {
      result.add('$inDays days');
    } else if (inDays == 1) {
      result.add('$inDays day');
    }

    // hours
    if (inHours.remainder(24) > 1) {
      result.add('${inHours.remainder(24)} hours');
    } else if (inHours.remainder(24) == 1) {
      result.add('${inHours.remainder(24)} hour');
    }
    // minutes
    if (inMinutes.remainder(60) > 1) {
      result.add('${inMinutes.remainder(60)} minutes');
    } else if (inMinutes.remainder(60) == 1) {
      result.add('${inMinutes.remainder(60)} minute');
    }

    // seconds
    if (NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().homeShowSeconds) {
      if (inSeconds.remainder(60) > 1) {
        result.add('${inSeconds.remainder(60)} seconds');
      } else if (inSeconds.remainder(60) == 1) {
        result.add('${inSeconds.remainder(60)} second');
      }
    }

    return result.join(' ');
  }
}
