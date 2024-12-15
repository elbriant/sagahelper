import 'dart:convert';
import 'dart:io';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum ServerProviderKeys {
  enVersion('enVersion'),
  cnVersion('cnVersion'),
  jpVersion('jpVersion'),
  krVersion('krVersion'),
  twVersion('twVersion');

  const ServerProviderKeys(
    this.key,
  );
  final String key;
}

class ServerProvider extends ChangeNotifier {
  static final Map<ServerProviderKeys, dynamic> _defaultValues = {
    ServerProviderKeys.enVersion: 'unknown',
    ServerProviderKeys.cnVersion: 'unknown',
    ServerProviderKeys.jpVersion: 'unknown',
    ServerProviderKeys.krVersion: 'unknown',
    ServerProviderKeys.twVersion: 'unknown',
  };

  String enVersion;
  String cnVersion;
  String jpVersion;
  String krVersion;
  String twVersion;

  ServerProvider({
    required this.enVersion,
    required this.cnVersion,
    required this.jpVersion,
    required this.krVersion,
    required this.twVersion,
  });

  static final List<String> files = [
    'character_table.json',
    'charword_table.json',
    'handbook_info_table.json',
    'handbook_team_table.json',
    'skin_table.json',
    'range_table.json',
    'skill_table.json',
  ];

  factory ServerProvider.fromConfig(Map configs) {
    return ServerProvider(
      enVersion: configs[ServerProviderKeys.enVersion.key] ?? _defaultValues[ServerProviderKeys.enVersion],
      cnVersion: configs[ServerProviderKeys.cnVersion.key] ?? _defaultValues[ServerProviderKeys.cnVersion],
      jpVersion: configs[ServerProviderKeys.jpVersion.key] ?? _defaultValues[ServerProviderKeys.jpVersion],
      krVersion: configs[ServerProviderKeys.krVersion.key] ?? _defaultValues[ServerProviderKeys.krVersion],
      twVersion: configs[ServerProviderKeys.twVersion.key] ?? _defaultValues[ServerProviderKeys.twVersion],
    );
  }

  static Future<Map<String, dynamic>> loadValues() async {
    return await LocalDataManager.readConfigMap(
      ServerProviderKeys.values.map((e) => e.key).toList(),
    );
  }

  static String yostarrepo(String server) => 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/refs/heads/main/$server/gamedata/excel';
  static final String chServerlink = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/refs/heads/master/zh_CN/gamedata/excel';

  String versionOf(String server) => switch (server) { 'en' => enVersion, 'cn' => cnVersion, 'jp' => jpVersion, 'kr' => krVersion, 'tw' => twVersion, String() => 'not found' };

  setVersion(String server, {String version = 'unknown'}) async {
    switch (server) {
      case 'en':
        enVersion = version;
        await LocalDataManager.writeConfigKey(
          ServerProviderKeys.enVersion.key,
          version,
        );
        break;
      case 'cn':
        cnVersion = version;
        await LocalDataManager.writeConfigKey(
          ServerProviderKeys.cnVersion.key,
          version,
        );
        break;
      case 'jp':
        jpVersion = version;
        await LocalDataManager.writeConfigKey(
          ServerProviderKeys.jpVersion.key,
          version,
        );
        break;
      case 'kr':
        krVersion = version;
        await LocalDataManager.writeConfigKey(
          ServerProviderKeys.krVersion.key,
          version,
        );
        break;
      case 'tw':
        twVersion = version;
        await LocalDataManager.writeConfigKey(
          ServerProviderKeys.twVersion.key,
          version,
        );
        break;
      default:
    }
    notifyListeners();
  }

  existFiles(String server, List<String> filesPaths) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server);

    for (var file in filesPaths) {
      bool fileExist = await File('$serverLocalPath/$file').exists();

      if (!fileExist) {
        throw Exception(404);
      }
    }

    return true;
  }

  Future<String> getFile(String filepath, String server) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server);
    return File('$serverLocalPath/$filepath').readAsString();
  }

  Future<bool> checkUpdateOf(String server) async {
    String update = await fetchLastestVersion(server);

    if (update != versionOf(server)) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> fetchLastestVersion(String server) async {
    String serverlink;
    if (server == 'cn') {
      serverlink = chServerlink;
    } else if (server == 'en' || server == 'jp' || server == 'kr') {
      serverlink = server == 'en'
          ? yostarrepo('en_US')
          : server == 'jp'
              ? yostarrepo('ja_JP')
              : yostarrepo('ko_KR');
    } else {
      throw Exception('not implemented');
    }

    final response = await http.get(Uri.parse('$serverlink/data_version.txt'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response
      const splitter = LineSplitter();
      final responseSplitted = splitter.convert(response.body);
      String result = '';

      for (var i = 0; i < responseSplitted.length; i++) {
        if (responseSplitted[i].startsWith('VersionControl:')) {
          result = responseSplitted[i].replaceFirst('VersionControl:', '').trim();
        }
      }

      return result;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<bool> checkFiles(String server) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server);
    String excelFolder = '$serverLocalPath/excel';

    for (var file in files) {
      bool fileExist = await File('$excelFolder/$file').exists();
      if (fileExist) {
        continue;
      } else {
        return false;
      }
    }

    return true;
  }

  void checkDownloadedLastest(String server, String version) async {
    bool result = await checkFiles(server);

    if (!result) return;

    setVersion(server, version: version);
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Completed download');
      await Future.delayed(const Duration(seconds: 2));
      if (NavigationService.navigatorKey.currentContext!.mounted) {
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingAsync(false);
      }
    }
  }

  downloadLastest(String server) async {
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Preparing download...');
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingAsync(true);
    }

    String serverlink;
    if (server == 'cn') {
      serverlink = chServerlink;
    } else if (server == 'en' || server == 'jp' || server == 'kr') {
      serverlink = server == 'en'
          ? yostarrepo('en_US')
          : server == 'jp'
              ? yostarrepo('ja_JP')
              : yostarrepo('ko_KR');
    } else {
      throw const FormatException('not implemented');
    }

    String serverLocalPath = await LocalDataManager.localpathServer(server);
    String excelFolder = '$serverLocalPath/excel';

    if (!Directory('$serverLocalPath/excel').existsSync()) {
      await Directory('$serverLocalPath/excel').create(recursive: true);
    }

    for (var file in files) {
      bool fileExist = await File('$excelFolder/$file').exists();
      if (fileExist) {
        await File('$excelFolder/$file').delete();
      }
    }

    // no version
    setVersion(server);

    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Starting download');
    }

    String version = await fetchLastestVersion(server);

    for (var file in files) {
      var downloaderUtils = DownloaderUtils(
        progressCallback: (current, total) {
          // final progress = (current / total) * 100;
        },
        file: File('$excelFolder/$file'),
        progress: ProgressImplementation(),
        onDone: () {
          if (NavigationService.navigatorKey.currentContext!.mounted) {
            NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('completed $file download...');
          }
          checkDownloadedLastest(server, version);
        },
        deleteOnCancel: true,
        onError: (_) {},
      );

      if (NavigationService.navigatorKey.currentContext!.mounted) {
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Starting $file download...');
      }

      List core = [];
      core.add(await Flowder.download('$serverlink/$file', downloaderUtils));
    }
  }
}
