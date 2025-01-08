import 'dart:convert';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

// ----------------- local data

Map<String, DownloaderCore> downloadsBackgroundCores = {};
bool firstTimeCheck = false;
bool serverFetchFlag = false;
bool checkForUpdatesFlag = false;
bool opThemed = false;

// ------------- constants

// Assets from yuanyan3060 repo
const String kAvatarRepo =
    'https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/refs/heads/main/avatar';
const String kSkillRepo =
    'https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/refs/heads/main/skill';
const String kBaseSkillRepo =
    'https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/refs/heads/main/building_skill';

// Assets from ArknightsAssets repo
const String kPortraitRepo =
    'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/charportraits';
const String kArtRepo =
    'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/characters';
const String kLogoRepo =
    'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/camplogo';
const String kModImgRepo =
    'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/refs/heads/cn/assets/torappu/dynamicassets/arts/ui/uniequipimg';
const String kModIconRepo =
    'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/refs/heads/cn/assets/torappu/dynamicassets/arts/ui/uniequiptype';
// Voice Assets from Aceship's repo
const String kVoiceRepo = 'https://github.com/Aceship/Arknight-voices/raw/refs/heads/main';

// ---------- helper classes

enum SnackBarType { normal, success, failure, warning, custom }

class ShowSnackBar {
  static void showSnackBar(
    String? text, {
    SnackBarType type = SnackBarType.normal,
    SnackBar? snackbar,
  }) {
    switch (type) {
      case SnackBarType.normal:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
            .showSnackBar(SnackBar(content: Text(text!)));
        break;
      case SnackBarType.success:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.done, color: Colors.green[700]),
                Text(text!),
              ],
            ),
            backgroundColor: Colors.green[50],
          ),
        );
        break;
      case SnackBarType.failure:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text!,
                    style: TextStyle(
                      color: Theme.of(
                        NavigationService.navigatorKey.currentContext!,
                      ).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.errorContainer,
          ),
        );
        break;
      case SnackBarType.warning:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber[600]),
                Text(text!),
              ],
            ),
            backgroundColor: Colors.amber[100],
          ),
        );
        break;
      case SnackBarType.custom:
        assert(snackbar != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
            .showSnackBar(snackbar!);
        break;
    }
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class LocalDataManager {
  static final String configPath = 'configs.txt';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get downloadPath async {
    String directory = "/storage/emulated/0/Download/";

    var dirDownloadExists = await Directory(directory).exists();
    if (dirDownloadExists) {
      directory = "/storage/emulated/0/Download/";
    } else {
      directory = "/storage/emulated/0/Downloads/";
    }
    return directory;
  }

  static Future<String> localpathServer(String server) async {
    final directory = await getApplicationDocumentsDirectory();
    if (Directory('${directory.path}/${server.toLowerCase()}').existsSync()) {
      return '${directory.path}/${server.toLowerCase()}';
    } else {
      await Directory('${directory.path}/${server.toLowerCase()}').create(recursive: true);
      return '${directory.path}/${server.toLowerCase()}';
    }
  }

  /* cache path
  Future<String> get _cachePath async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }
  */

  static Future<File> localFile(String filePath) async {
    final path = await _localPath;
    var dirExists = await File('$path/$filePath').exists();

    if (dirExists == true) {
      return File('$path/$filePath');
    } else {
      return File('$path/$filePath').create(recursive: true);
    }
  }

  static Future<void> writeConfigKey(String key, dynamic data) async {
    final file = await localFile(configPath);
    // read json
    final contents = await file.readAsString();
    var parsed = <String, dynamic>{};
    if (contents != '') {
      // decode json to map
      parsed = jsonDecode(contents) as Map<String, dynamic>;
    }
    // save data in json
    parsed[key] = data;
    // encode json
    final encoded = jsonEncode(parsed);
    // Write json to the file
    await file.writeAsString(encoded);
  }

  static Future<void> writeConfigMap(Map<String, dynamic> map) async {
    final file = await localFile(configPath);
    // read json
    final contents = await file.readAsString();
    var parsed = <String, dynamic>{};
    if (contents != '') {
      // decode json to map
      parsed = jsonDecode(contents) as Map<String, dynamic>;
    }
    // save data in json
    map.forEach((key, value) {
      parsed[key] = value;
    });
    // encode json
    final encoded = jsonEncode(parsed);
    // Write json to the file
    await file.writeAsString(encoded);
  }

  static Future<dynamic> readConfigKey(String key) async {
    try {
      final file = await localFile(configPath);
      // Read the file
      final contents = await file.readAsString();
      // decode json to map
      final parsed = jsonDecode(contents) as Map<String, dynamic>;

      if (parsed.containsKey(key)) {
        return parsed[key];
      } else {
        return null;
      }
    } catch (e) {
      //just in case
      return null;
    }
  }

  static Future<Map<String, dynamic>> readConfigMap(List<String> keys) async {
    final file = await localFile(configPath);
    // Read the file
    final contents = await file.readAsString();
    // decode json to map
    final parsed = jsonDecode(contents) as Map<String, dynamic>;

    final List<MapEntry<String, dynamic>> values = [];
    for (String key in keys) {
      dynamic val;
      if (parsed.containsKey(key)) {
        val = parsed[key];
        dev.log('[LDM] - key [$key] - value $val');
      } else {
        dev.log('[LDM] - key [$key] doesnt exists');
      }
      values.add(MapEntry(key, val));
    }

    return Map.fromEntries(values);
  }

  static Future<bool> existConfig() async {
    final file = await localFile(configPath);
    // Read the file
    final contents = await file.readAsString();

    if (contents == '') {
      return false;
    } else {
      return true;
    }
  }

  static Future<void> resetConfig() async {
    final file = await localFile(configPath);
    await file.delete();
  }
}

class StaticColors {
  static BuildContext get navContext => NavigationService.navigatorKey.currentContext!;
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

  //ak colors
  final Color akBlue;
  final Color akRed;

  StaticColors({
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
    required this.akBlue,
    required this.akRed,
  });

  factory StaticColors.light() {
    return StaticColors(
      green: const Color(0xFF005e1b),
      onGreen: const Color(0xFFffffff),
      greenVariant: const Color(0xFF5cbb62),
      onGreenVariant: const Color(0xFF002205),
      blue: const Color(0xFF00538a),
      onBlue: const Color(0xFFffffff),
      blueVariant: const Color(0xFF0076d2),
      onBlueVariant: const Color(0xFFffffff),
      yellow: const Color(0xFF6a5f00),
      onYellow: const Color(0xFFffffff),
      yellowVariant: const Color(0xFFffc124),
      onYellowVariant: const Color(0xFF4b3600),
      red: const Color(0xFFa5000b),
      onRed: const Color(0xFFffffff),
      redVariant: const Color(0xFFe51f03),
      onRedVariant: const Color(0xFFffffff),
      orange: const Color(0xFFa14000),
      onOrange: const Color(0xFFffffff),
      orangeVariant: const Color(0xFFff9058),
      onOrangeVariant: const Color(0xFF401500),
      sHp: const Color.fromARGB(255, 92, 143, 17),
      sAtk: const Color.fromARGB(255, 163, 47, 47),
      sRedeploy: const Color.fromARGB(255, 170, 52, 111),
      sDef: const Color.fromARGB(255, 10, 125, 179),
      sCost: const Color.fromARGB(255, 138, 138, 138),
      sAspd: const Color.fromARGB(255, 182, 147, 58),
      sRes: const Color.fromARGB(255, 106, 71, 189),
      sBlock: const Color.fromARGB(255, 91, 90, 168),
      akBlue: const Color.fromARGB(255, 0, 120, 175),
      akRed: const Color.fromARGB(255, 199, 77, 43),
    );
  }

  factory StaticColors.dark() {
    return StaticColors(
      green: const Color(0xFF83da84),
      onGreen: const Color(0xFF00390d),
      greenVariant: const Color(0xFF47a54f),
      onGreenVariant: const Color(0xFF000000),
      blue: const Color(0xFF9ccaff),
      onBlue: const Color(0xFF003257),
      blueVariant: const Color(0xFF0076d2),
      onBlueVariant: const Color(0xFFffffff),
      yellow: const Color(0xFFf6e138),
      onYellow: const Color(0xFF373100),
      yellowVariant: const Color(0xFFf2b400),
      onYellowVariant: const Color(0xFF402d00),
      red: const Color(0xFFffb4aa),
      onRed: const Color(0xFF690004),
      redVariant: const Color(0xFFe51f03),
      onRedVariant: const Color(0xFFffffff),
      orange: const Color(0xFFffb694),
      onOrange: const Color(0xFF571f00),
      orangeVariant: const Color(0xFFf77833),
      onOrangeVariant: const Color(0xFF1f0700),
      sHp: const Color.fromARGB(255, 132, 204, 22),
      sAtk: const Color.fromARGB(255, 239, 68, 68),
      sRedeploy: const Color.fromARGB(255, 236, 72, 153),
      sDef: const Color.fromARGB(255, 14, 165, 233),
      sCost: const Color.fromARGB(255, 223, 223, 223),
      sAspd: const Color(0xFFffcf53),
      sRes: const Color.fromARGB(255, 139, 92, 246),
      sBlock: const Color(0xFF7f7dea),
      akBlue: const Color(0xFF0098DC),
      akRed: const Color(0xFFFF6237),
    );
  }

  factory StaticColors.fromBrightness(BuildContext? context) {
    final brightness = Theme.of(context ?? navContext).brightness;

    if (brightness == Brightness.light) {
      return StaticColors.light();
    } else {
      return StaticColors.dark();
    }
  }
}

class Calc {
  static AxisDirection? valueDifference(num current, num last) {
    if (current < last) {
      return AxisDirection.down;
    } else if (current == last) {
      return null;
    } else {
      return AxisDirection.up;
    }
  }
}
