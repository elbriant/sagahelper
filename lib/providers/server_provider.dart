import 'dart:convert';
import 'dart:io';

import 'package:docsprts/providers/settings_provider.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:docsprts/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ServerProvider extends ChangeNotifier {
  String enVersion = 'unknown';
  String cnVersion = 'unknown';
  String jpVersion = 'unknown';
  String krVersion = 'unknown';
  String twVersion = 'unknown';

  List<String> files = [
    'character_table.json',
    'charword_table.json',
    'handbook_info_table.json',
    'handbook_team_table.json',
  ];

  String yostarrepo(String server) => 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/refs/heads/main/$server/gamedata/excel';

  String chServerlink = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/refs/heads/master/zh_CN/gamedata/excel';

  final _configs = LocalDataManager();

  writeDefaultValues() async {
    return await _configs.writeConfigMap({
      'enVersion' : 'unknown',
      'cnVersion' : 'unknown',
      'jpVersion' : 'unknown',
      'krVersion' : 'unknown',
      'twVersion' : 'unknown',
    });
  }

  setDefaultValues() {
    enVersion = 'unknown';
    cnVersion = 'unknown';
    jpVersion = 'unknown';
    krVersion = 'unknown';
    twVersion = 'unknown';
  }

  loadValues() async {
    return {
      'enVersion' : await _configs.readConfig('enVersion'),
      'cnVersion' : await _configs.readConfig('cnVersion'),
      'jpVersion' : await _configs.readConfig('jpVersion'),
      'krVersion' : await _configs.readConfig('krVersion'),
      'twVersion' : await _configs.readConfig('twVersion'),
    };
  }

  setValues(Map configs) {
    enVersion = configs['enVersion'];
    cnVersion = configs['cnVersion'];
    jpVersion = configs['jpVersion'];
    krVersion = configs['krVersion'];
    twVersion = configs['twVersion'];
  }

  String versionOf(String server) => switch (server) {
    'en' => enVersion,
    'cn' => cnVersion,
    'jp' => jpVersion,
    'kr' => krVersion,
    'tw' => twVersion,
    String() => 'not found'
  };

  setVersion (String server, {String version = 'unknown'}) async {
    switch (server) {
      case 'en':
        enVersion = version;
        await _configs.writeConfigKey('enVersion', version);
        break;
      case 'cn':
        cnVersion = version;
        await _configs.writeConfigKey('cnVersion', version);
        break;
      case 'jp':
        jpVersion = version;
        await _configs.writeConfigKey('jpVersion', version);
        break;
      case 'kr':
        krVersion = version;
        await _configs.writeConfigKey('krVersion', version);
        break;
      case 'tw':
        twVersion = version;
        await _configs.writeConfigKey('twVersion', version);
        break;
      default:
    }
    notifyListeners();
  }

  existFiles(String server, List<String> filesPaths) async {
    String serverLocalPath = await LocalDataManager().localpathServer(server);

    for (var file in filesPaths) {
      bool fileExist = await File('$serverLocalPath/$file').exists();

      if (!fileExist) {
        throw Exception(404);
      }
    }

    return true;
  }

  Future<String> getFile(String filepath, String server) async {
    String serverLocalPath = await LocalDataManager().localpathServer(server);
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
      serverlink = server == 'en' ? yostarrepo('en_US') : server == 'jp' ? yostarrepo('ja_JP') : yostarrepo('ko_KR');
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

  void checkDownloadedLastest(String server, String version) async {
    String serverLocalPath = await LocalDataManager().localpathServer(server);
    String excelFolder = '$serverLocalPath/excel';

    for (var file in files) {
      bool fileExist = await File('$excelFolder/$file').exists();
      if (fileExist) {
        continue;
      } else {
        return;
      }
    }

    
    setVersion(server, version: version);
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Completed download');
      await Future.delayed(const Duration(seconds: 2));
      if (NavigationService.navigatorKey.currentContext!.mounted) NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingAsync(false);
    }
  }

  downloadLastest(String server) async {
    var ldm = LocalDataManager();

    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Preparing download...');
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingAsync(true);
    }
    
    String serverlink;
    if (server == 'cn') {
      serverlink = chServerlink;
    } else if (server == 'en' || server == 'jp' || server == 'kr') {
      serverlink = server == 'en' ? yostarrepo('en_US') : server == 'jp' ? yostarrepo('ja_JP') : yostarrepo('ko_KR');
    } else {
      throw const FormatException('not implemented');
    }

    String serverLocalPath = await ldm.localpathServer(server);
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
          //final progress = (current / total) * 100;
          // TODO notif progress bar
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
      );

      if (NavigationService.navigatorKey.currentContext!.mounted) {
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('Starting $file download...');
      }
              
      List core = [];
      core.add(await Flowder.download('$serverlink/$file', downloaderUtils));
    }
  

  }
}
