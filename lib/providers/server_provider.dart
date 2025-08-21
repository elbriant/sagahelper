import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/models/dir_stat.dart';
import 'package:sagahelper/models/server_state.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:flowder/flowder.dart';
import 'package:http/http.dart' as http;

enum Server {
  en('enVersion', 'en_US', 'en'),
  cn('cnVersion', '', 'cn'),
  jp('jpVersion', 'ja_JP', 'jp'),
  kr('krVersion', 'ko_KR', 'kr');

  const Server(
    this.key,
    this.repoString,
    this.folderLabel,
  );
  final String key;
  final String repoString;
  final String folderLabel;
  String get serverString => folderLabel.toUpperCase();

  int toJson() => index;
  static Server? fromJson(int? index) => index != null ? Server.values[index] : null;
}

const List<String> kHomeFiles = [
  '/excel/stage_table.json', // 0 for now just used to know if weekly supply are forcefully open
];

const List<String> kMetadataFiles = [
  '/excel/handbook_team_table.json', // 0 factions
  '/excel/char_patch_table.json', // 1 amiyi changes
  '/excel/char_meta_table.json', // 2 related ops alters
  '/excel/gamedata_const.json', // 3 for now only for game terminology dictionary
  '/excel/gacha_table.json', // 4 for now just to extract tag list from recruitment
];

const List<String> kOpFiles = [
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

const Set<String> kFiles = {...kHomeFiles, ...kMetadataFiles, ...kOpFiles};

String yostarrepo(String server) =>
    'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/refs/heads/main/$server/gamedata';
const String chServerlink =
    'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/refs/heads/master/zh_CN/gamedata';

final serverProvider =
    AsyncNotifierProvider.autoDispose.family<ServerNotifier, ServerState, Server>(
  ServerNotifier.new,
);

/// Provider que expone el notifier del servidor actual
final currentServerNotifierProvider = Provider<ServerNotifier>((ref) {
  final currentServer = ref.watch(configProvider.select((p) => p.currentServer));
  return ref.watch(serverProvider(currentServer).notifier);
});

/// Provider que expone el estado del servidor actual
final currentServerStateProvider = Provider<AsyncValue<ServerState>>((ref) {
  final currentServer = ref.watch(configProvider.select((p) => p.currentServer));
  return ref.watch(serverProvider(currentServer));
});

class ServerNotifier extends FamilyAsyncNotifier<ServerState, Server> {
  String get serverlink =>
      switch (arg) { Server.cn => chServerlink, _ => yostarrepo(arg.repoString) };

  @override
  ServerState build(Server server) {
    final prefs = ref.watch(sharedPreferencesProvider);

    return ServerState(version: prefs.getString(server.key));
  }

  Future<void> setVersion(String? version) async {
    final prefs = ref.watch(sharedPreferencesProvider);
    await prefs.setString(arg.key, version ?? '');

    final prevState = await future;

    state = AsyncData(prevState.copyWith(version: version));
  }

  /// [filePaths] null means all files
  Future<bool> existFiles([List<String>? filesPaths]) async {
    String serverLocalPath = await LocalDataManager.localpathServer(arg.folderLabel);

    for (var file in (filesPaths ?? kFiles)) {
      bool fileExist = await File('$serverLocalPath$file').exists();

      if (!fileExist) {
        return false;
      }
    }

    return true;
  }

  Future<String> getFile(String filepath) async {
    String serverLocalPath = await LocalDataManager.localpathServer(arg.folderLabel);
    return File('$serverLocalPath$filepath').readAsString();
  }

  Future<String?> tryGetFile(String filepath) async {
    String serverLocalPath = await LocalDataManager.localpathServer(arg.folderLabel);
    if ((await File('$serverLocalPath$filepath').exists())) {
      return await File('$serverLocalPath$filepath').readAsString();
    } else {
      return null;
    }
  }

  Future<String> fetchLastestVersion() async {
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

  Future<void> checkUpdate() async {
    final prevState = await future;
    state = AsyncValue.data(
      prevState.copyWith(state: DataState.fetching),
    );

    try {
      final updateString = await fetchLastestVersion();
      final hasAllFiles = await existFiles();
      if (updateString != (prevState.version ?? '') || !hasAllFiles) {
        state = AsyncValue.data(
          prevState.copyWith(
            state: DataState.hasUpdate,
          ),
        );
      } else {
        state = AsyncValue.data(
          prevState.copyWith(
            state: DataState.upToDate,
          ),
        );
      }
    } catch (_) {
      state = AsyncValue.data(
        prevState.copyWith(
          state: DataState.error,
        ),
      );
    }
  }

  Future<void> updateFolderSize() async {
    String serverLocalPath = await LocalDataManager.localpathServer(arg.folderLabel);

    String serverSize = await DirStat.getDirStat(serverLocalPath).then((dirStat) {
      return dirStat.totalSizeString;
    });

    final prevState = await future;

    state = AsyncData(
      prevState.copyWith(
        folderSize: (serverSize != '0 B') ? serverSize : null,
      ),
    );
  }

  void verifyDownloadedLastest(String version) async {
    final result = await existFiles();

    if (!result) return;

    await setVersion(version);
    await updateFolderSize();

    /* TODO: tasker
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
    */

    final prevState = await future;
    state = AsyncData(
      prevState.copyWith(
        state: DataState.upToDate,
      ),
    );
  }

  Future<void> downloadLastest() async {
    /* TODO: tasker
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('Preparing download...');
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setIsLoadingAsync(true);
    }
    */

    final prevState = await future;
    state = AsyncData(
      prevState.copyWith(
        state: DataState.downloading,
      ),
    );

    String serverLocalPath = await LocalDataManager.localpathServer(arg.folderLabel);

    for (var file in kFiles) {
      bool fileExist = await File('$serverLocalPath$file').exists();
      if (fileExist) {
        await File('$serverLocalPath$file').delete();
      }
    }

    // no version
    await setVersion(null);

    /* TODO: tasker
    if (NavigationService.navigatorKey.currentContext!.mounted) {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('Starting download');
    }
 */

    String version = await fetchLastestVersion();

    for (var file in kFiles) {
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
          /* TODO: tasker
          
          if (NavigationService.navigatorKey.currentContext!.mounted) {
            NavigationService.navigatorKey.currentContext!
                .read<SettingsProvider>()
                .setLoadingString('completed $msgfile download...');
          } */
          verifyDownloadedLastest(version);
        },
        deleteOnCancel: true,
        onError: (_) {},
      );

      /* TODO: tasker
      
       if (NavigationService.navigatorKey.currentContext!.mounted) {
        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setLoadingString('Starting $msgfile download...');
      } */

      List core = [];
      core.add(await Flowder.download('$serverlink$file', downloaderUtils));
    }
  }

  Future<void> deleteServer() async {
    String serverLocalPath = await LocalDataManager.localpathServer(arg.folderLabel);

    if (await Directory(serverLocalPath).exists()) {
      await Directory(serverLocalPath).delete(recursive: true);
    }
    await updateFolderSize();
    // no version
    await setVersion(null);
  }
}
