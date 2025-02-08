import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:sagahelper/models/dir_stat.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/global_data.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum Servers {
  en('enVersion', 'en_US', 'en'),
  cn('cnVersion', '', 'cn'),
  jp('jpVersion', 'ja_JP', 'jp'),
  kr('krVersion', 'ko_KR', 'kr');

  const Servers(
    this.key,
    this.repoString,
    this.folderLabel,
  );
  final String key;
  final String repoString;
  final String folderLabel;

  int toJson() => index;
  static Servers? fromJson(int? index) => index != null ? Servers.values[index] : null;
}

enum DataState {
  fetching,
  hasUpdate,
  upToDate,
  error,
  downloading,
}

class ServerProvider extends ChangeNotifier {
  static final Map<Servers, dynamic> _defaultValues = {
    Servers.en: '',
    Servers.cn: '',
    Servers.jp: '',
    Servers.kr: '',
  };

  String enVersion;
  String cnVersion;
  String jpVersion;
  String krVersion;

  DataState enState = DataState.fetching;
  DataState cnState = DataState.fetching;
  DataState jpState = DataState.fetching;
  DataState krState = DataState.fetching;

  Map<Servers, String> folderSize = {};

  ServerProvider({
    required this.enVersion,
    required this.cnVersion,
    required this.jpVersion,
    required this.krVersion,
  });

  static List<String> get files {
    var a = <String>[];
    a.addAll(metadataFiles);
    a.addAll(opFiles);
    return a;
  }

  static final List<String> metadataFiles = [
    '/excel/handbook_team_table.json', // 0 factions
    '/excel/char_patch_table.json', // 1 amiyi changes
    '/excel/char_meta_table.json', // 2 related ops alters
    '/excel/gamedata_const.json', // 3 for now only for game terminology dictionary
    '/excel/gacha_table.json', // 4 for now just to extract tag list from recruitment
  ];

  static final List<String> opFiles = [
    '/excel/character_table.json', // 0 operators
    '/excel/handbook_info_table.json', // 1 lore
    '/excel/charword_table.json', // 2 voice
    '/excel/skin_table.json', // 3 skin
    '/excel/range_table.json', // 4 ranges
    '/excel/skill_table.json', // 5 skills details
    '/excel/uniequip_table.json', // 6 modules
    '/excel/building_data.json', // 7 base skills
    '/excel/battle_equip_table.json', // 8 module stats
  ];

  factory ServerProvider.fromConfig(Map configs) {
    return ServerProvider(
      enVersion: configs[Servers.en.key] ?? _defaultValues[Servers.en],
      cnVersion: configs[Servers.cn.key] ?? _defaultValues[Servers.cn],
      jpVersion: configs[Servers.jp.key] ?? _defaultValues[Servers.jp],
      krVersion: configs[Servers.kr.key] ?? _defaultValues[Servers.kr],
    );
  }

  static Future<Map<String, dynamic>> loadValues() async {
    return await LocalDataManager.readConfigMap(
      Servers.values.map((e) => e.key).toList(),
    );
  }

  static String yostarrepo(String server) =>
      'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/refs/heads/main/$server/gamedata';
  static final String chServerlink =
      'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/refs/heads/master/zh_CN/gamedata';

  String versionOf(Servers server) => switch (server) {
        Servers.en => enVersion,
        Servers.cn => cnVersion,
        Servers.jp => jpVersion,
        Servers.kr => krVersion,
      };

  void setVersion(Servers server, {String version = ''}) async {
    switch (server) {
      case Servers.en:
        enVersion = version;
      case Servers.cn:
        cnVersion = version;
      case Servers.jp:
        jpVersion = version;
      case Servers.kr:
        krVersion = version;
    }
    await LocalDataManager.writeConfigKey(
      server.key,
      version,
    );
    notifyListeners();
  }

  Future<bool> existFiles(Servers server, List<String> filesPaths) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server.folderLabel);

    for (var file in filesPaths) {
      bool fileExist = await File('$serverLocalPath$file').exists();

      if (!fileExist) {
        return false;
      }
    }

    return true;
  }

  Future<String> getFile(String filepath, Servers server) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server.folderLabel);
    return File('$serverLocalPath$filepath').readAsString();
  }

  Future<bool> checkUpdateOf(Servers server) async {
    String update = await fetchLastestVersion(server);

    return (update != versionOf(server));
  }

  Future<String> fetchLastestVersion(Servers server) async {
    String serverlink =
        switch (server) { Servers.cn => chServerlink, _ => yostarrepo(server.repoString) };

    final response = await http.get(Uri.parse('$serverlink/excel/data_version.txt'));

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
      throw Exception('Failed to load');
    }
  }

  Future<bool> checkAllFiles(Servers server) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server.folderLabel);

    for (var file in files) {
      bool fileExist = await File('$serverLocalPath$file').exists();

      if (!fileExist) return false;
    }

    return true;
  }

  void checkDownloadedLastest(Servers server, String version) async {
    bool result = await checkAllFiles(server);

    if (!result) return;

    setVersion(server, version: version);
    getFolderSize(server);
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('Completed download');
      await Future.delayed(const Duration(seconds: 2));
      if (NavigationService.navigatorKey.currentContext!.mounted) {
        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setIsLoadingAsync(false);
      }
      NavigationService.navigatorKey.currentContext!
          .read<ServerProvider>()
          .setSingleServerState(server, DataState.upToDate);
    }
  }

  Future<void> downloadLastest(Servers server) async {
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('Preparing download...');
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setIsLoadingAsync(true);
    }

    String serverlink =
        switch (server) { Servers.cn => chServerlink, _ => yostarrepo(server.repoString) };

    String serverLocalPath = await LocalDataManager.localpathServer(server.folderLabel);

    if (!(await Directory(serverLocalPath).exists())) {
      await Directory(serverLocalPath).create(recursive: true);
    }

    for (var file in files) {
      bool fileExist = await File('$serverLocalPath$file').exists();
      if (fileExist) {
        await File('$serverLocalPath$file').delete();
      }
    }
    // no version
    setVersion(server);

    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('Starting download');
    }

    String version = await fetchLastestVersion(server);

    for (var file in files) {
      final String msgfile = file.substring(
        max(0, file.lastIndexOf('/') + 1),
        file.lastIndexOf('.') > 0 ? file.lastIndexOf('.') : file.length - 1,
      );

      var downloaderUtils = DownloaderUtils(
        progressCallback: (current, total) {
          // final progress = (current / total) * 100;
        },
        file: File('$serverLocalPath$file'),
        progress: ProgressImplementation(),
        onDone: () {
          if (NavigationService.navigatorKey.currentContext!.mounted) {
            NavigationService.navigatorKey.currentContext!
                .read<SettingsProvider>()
                .setLoadingString('completed $msgfile download...');
          }
          checkDownloadedLastest(server, version);
        },
        deleteOnCancel: true,
        onError: (_) {},
      );

      if (NavigationService.navigatorKey.currentContext!.mounted) {
        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setLoadingString('Starting $msgfile download...');
      }

      List core = [];
      core.add(await Flowder.download('$serverlink$file', downloaderUtils));
    }
  }

  Future<DataState> getServerStatus(Servers server) async {
    DataState status;
    try {
      bool result = await checkUpdateOf(server);
      bool fileIntegrity = await checkAllFiles(server);

      if (result || !fileIntegrity) {
        status = DataState.hasUpdate;
      } else {
        status = DataState.upToDate;
      }
    } catch (e) {
      status = DataState.error;
    }

    return status;
  }

  void setSingleServerState(Servers server, DataState state) {
    switch (server) {
      case Servers.en:
        enState = state;
      case Servers.cn:
        cnState = state;
      case Servers.jp:
        jpState = state;
      case Servers.kr:
        krState = state;
    }
    notifyListeners();
  }

  Future<void> deleteServer(Servers server) async {
    String serverLocalPath = await LocalDataManager.localpathServer(server.folderLabel);

    if (await Directory(serverLocalPath).exists()) {
      await Directory(serverLocalPath).delete(recursive: true);
    }
    getFolderSize(server);
    // no version
    setVersion(server);
  }

  Future<void> getFolderSize(Servers server) async {
    Map<Servers, String> newSize = Map.of(folderSize);
    String serverLocalPath = await LocalDataManager.localpathServer(server.folderLabel);

    String serverSize = await DirStat.getDirStat(serverLocalPath).then((dirStat) {
      return dirStat.totalSizeString;
    });

    if (serverSize != '0 B') {
      newSize[server] = serverSize;
    } else {
      newSize.remove(server);
    }

    folderSize = newSize;
    notifyListeners();
  }
}
