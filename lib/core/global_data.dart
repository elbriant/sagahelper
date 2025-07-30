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

const Map<String, Map> credits = {
  "Kengxxiao - ArknightsGameData": {
    "assets": "Providing the raw game data",
    "link": "https://github.com/Kengxxiao/ArknightsGameData",
  },
  "elbriant - Sagapi-assets": {
    "assets": "Various assets from CN data",
    "link": "https://github.com/elbriant/sagapi-assets/",
  },
  "elbriant - Sagapi-audio": {
    "assets": "Operators voicelines",
    "link": "https://github.com/elbriant/sagapi-audio/",
  },
  "Seseren - Twitter/X": {
    "assets": "Saga gifs",
    "link": "https://twitter.com/Seseren_kr",
  },
  "Arknights - hypergryph": {
    "assets":
        "Arknights is a trademark of Hypergryph and Yostar. \n This fan app is not officially affiliated with or endorsed by Hypergryph or Yostar. \n All rights to the Arknights intellectual property belong to their respective owners.",
    "link": "https://ak.hypergryph.com",
  },
};

// Assets from sagapi-assets repo
const String kAvatarRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/charavatars';
const String kSkillRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/skills';
const String kBaseSkillRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/building_skill';
const String kTokenAvatarRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/charavatars';
const String kPortraitRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/charportraits';
const String kArtRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/chararts';
const String kLogoRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/logo';
const String kModImgRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/ui/uniequipimg';
const String kModIconRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/ui/uniequiptype';

// Voice Assets from sagapi-audio repo
const String kVoiceRepo = 'https://github.com/elbriant/sagapi-audio/raw/refs/heads/audio/audio';

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
  static late final String _localPath;
  static late final String _cachePath;

  static Future<void> initDirectories() async {
    _localPath = (await getApplicationDocumentsDirectory()).path;
    _cachePath = (await getApplicationCacheDirectory()).path;
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

  static Future<File> localCacheFile(String filePath, [bool justDirectory = false]) async {
    final path = _cachePath;

    if (justDirectory) {
      final completePath = '$path/$filePath';
      var folderPath = completePath.split(r'/');
      folderPath.removeLast();

      final dirExists = await Directory(folderPath.join('/')).exists();

      if (!dirExists) {
        await Directory(folderPath.join('/')).create(recursive: true);
      }

      return File('$path/$filePath');
    }

    var dirExists = await File('$path/$filePath').exists();
    if (dirExists == true) {
      return File('$path/$filePath');
    } else {
      return await File('$path/$filePath').create(recursive: true);
    }
  }

  static File localCacheFileSync(String filepath) {
    final path = _cachePath;
    final completePath = '$path/$filepath';
    var folderPath = completePath.split(r'/');
    folderPath.removeLast();

    final dirExists = Directory(folderPath.join('/')).existsSync();

    if (!dirExists) {
      Directory(folderPath.join('/')).createSync(recursive: true);
    }

    return File('$path/$filepath');
  }

  static Future<File> localFile(String filePath) async {
    final path = _localPath;
    var dirExists = await File('$path/$filePath').exists();

    if (dirExists == true) {
      return File('$path/$filePath');
    } else {
      return await File('$path/$filePath').create(recursive: true);
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
  final Color sAspdPercent;

  final Color sBonus;
  final Color sBonusText;

  //ak colors
  final Color akAttrUp;
  final Color akAttrDown;
  final Color akKeyword;

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
