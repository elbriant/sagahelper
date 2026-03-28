import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/core/snack_bar_service.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/models/dir_stat.dart';
import 'package:sagahelper/models/server_state.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:flowder/flowder.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sagahelper/providers/tasker_provider.dart';

enum Server {
  cn('cnVersion', 'cn', 'cn'),
  en('enVersion', 'en', 'en'),
  jp('jpVersion', 'jp', 'jp'),
  kr('krVersion', 'kr', 'kr'),
  tw('twVersion', 'tw', 'tw');

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

final serverProvider = NotifierProvider.family<ServerNotifier, ServerState, Server>(
  ServerNotifier.new,
);

/// Provider que expone el notifier del servidor actual
final currentServerNotifierProvider = Provider<ServerNotifier>((ref) {
  final currentServer = ref.watch(configProvider.select((p) => p.currentServer));
  return ref.watch(serverProvider(currentServer).notifier);
});

/// Provider que expone el estado del servidor actual
final currentServerStateProvider = Provider<ServerState>((ref) {
  final currentServer = ref.watch(configProvider.select((p) => p.currentServer));
  return ref.watch(serverProvider(currentServer));
});

class ServerNotifier extends Notifier<ServerState> {
  ServerNotifier(this.server);
  final Server server;
  late final String serverLocalPath;
  late final String serverLink;

  @override
  ServerState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    serverLocalPath = LocalDataManager.localpathServer(server);
    serverLink = gamedataRepo(server);
    final version = prefs.getString(server.key);

    return ServerState(
      server: server,
      version: (version ?? '').isEmpty ? null : version,
    );
  }

  /// deletes initial "/" if has one and returns filepath of this server file
  String _getSafePath(String relativePath) {
    final cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return p.join(serverLocalPath, cleanPath);
  }

  /// returns the future string of a certain server file (downloaded)
  Future<String> getFile(String filepath) async {
    return await File(_getSafePath(filepath)).readAsString();
  }

  /// safer version of getFile
  Future<String?> tryGetFile(String filepath) async {
    if ((await File(_getSafePath(filepath)).exists())) {
      return await File(_getSafePath(filepath)).readAsString();
    } else {
      return null;
    }
  }

  /// sets the version [String] to the provided server
  Future<void> setVersion(String? version) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(server.key, version ?? '');
    state = state.copyWith(version: version);
  }

  /// [filePaths] null means all files
  Future<bool> existFiles([List<String>? filesPaths]) async {
    for (var file in (filesPaths ?? kFiles)) {
      bool fileExist = await File(_getSafePath(file)).exists();
      if (!fileExist) {
        return false;
      }
    }

    return true;
  }

  /// fetch last data version available for the provided server
  /// returns [String] version
  Future<String> fetchLastestVersion() async {
    final response = await http.get(Uri.parse('$serverLink/excel/data_version.txt'));

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

  /// checks either if theres new version of the provided server
  /// or if theres a problem with any of the server files
  /// updates the folder size too
  /// check the dataState to know
  Future<void> refresh() async {
    updateFolderSize();

    if (state.state == DataState.fetching || state.state == DataState.downloading) return;

    state = state.copyWith(state: DataState.fetching);

    try {
      final updateString = await fetchLastestVersion();
      final hasAllFiles = await existFiles();
      if (updateString != (state.version ?? '') || !hasAllFiles) {
        state = state.copyWith(
          state: DataState.hasUpdate,
        );
      } else {
        state = state.copyWith(
          state: DataState.upToDate,
        );
      }
    } catch (_) {
      state = state.copyWith(
        state: DataState.error,
      );
    }
  }

  /// updates the folder size of the provided server
  Future<void> updateFolderSize() async {
    String serverSize = await DirStat.getDirStat(serverLocalPath).then((dirStat) {
      return dirStat.totalSizeString;
    });

    state = state.copyWith(
      folderSize: (serverSize != '0 B') ? serverSize : null,
    );
  }

  /// verifies if all files are alright and sets the version to the given version
  void verifyDownloadedLastest(String version, {String? taskId}) async {
    final result = await existFiles();

    if (!result) return;

    await setVersion(version);
    await updateFolderSize();

    if (taskId != null) {
      ref.read(taskerProvider.notifier).updateTask(taskId, 'Completed download ≧◡≦');
      Future.delayed(const Duration(seconds: 2)).then((_) {
        ref.read(taskerProvider.notifier).removeTask(taskId);
      });
    }
    state = state.copyWith(
      state: DataState.upToDate,
    );
  }

  /// deletes and tries to download the last version
  Future<void> downloadLastest() async {
    final taskId = ref.read(taskerProvider.notifier).addTask('Preparing download...');

    await deleteServer();

    state = state.copyWith(
      state: DataState.downloading,
    );

    ref.read(taskerProvider.notifier).updateTask(taskId, 'Starting download...');

    String version = await fetchLastestVersion();

    List<Future<void>> downloadTasks = [];

    for (var file in kFiles) {
      final String msgfile = file.substring(
        max(0, file.lastIndexOf('/') + 1),
        file.lastIndexOf('.') > 0 ? file.lastIndexOf('.') : file.length - 1,
      );

      final completer = Completer<void>();

      var downloaderUtils = DownloaderUtils(
        file: File(_getSafePath(file)),
        onDone: () {
          ref.read(taskerProvider.notifier).updateTask(taskId, 'Completed $msgfile download...');
          completer.complete();
        },
        onError: (e) => completer.completeError(e),
        progressCallback: (current, total) {
          // final progress = (current / total) * 100;
        },
        progress: ProgressImplementation(),
        deleteOnCancel: true,
      );

      ref.read(taskerProvider.notifier).updateTask(taskId, 'Starting $msgfile download...');
      try {
        await Flowder.download('$serverLink$file', downloaderUtils);
        downloadTasks.add(completer.future);
      } catch (e) {
        ref.read(taskerProvider.notifier).updateTask(taskId, 'Error with $msgfile');
        Future.delayed(const Duration(seconds: 2)).then((_) {
          ref.read(taskerProvider.notifier).removeTask(taskId);
        });
        state = state.copyWith(
          state: DataState.error,
        );
        SnackBarService.showSnackBar('Server download error: $e', type: SnackBarType.failure);
      }
    }

    try {
      await Future.wait(downloadTasks);
      verifyDownloadedLastest(version, taskId: taskId);
    } catch (e) {
      state = state.copyWith(state: DataState.error);
    }
  }

  /// deletes all files related to this server
  Future<void> deleteServer() async {
    if (await Directory(serverLocalPath).exists()) {
      await Directory(serverLocalPath).delete(recursive: true);
    }
    updateFolderSize();
    // no version
    await setVersion(null);

    state = state.copyWith(state: DataState.unknown);
  }
}
