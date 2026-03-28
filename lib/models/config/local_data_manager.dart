import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sagahelper/providers/server_provider.dart';

enum CacheType {
  /// anything apparently
  images('images'),

  /// base skill, the one that affects the riic
  baseSkill('baseicon'),

  /// module icon
  moduleIcon('modicon'),

  /// module art
  moduleArt('modart'),

  /// operator (or entity) skill icon
  skillIcon('skillicon'),

  /// operator (or entity) full art
  operatorArt('opart'),

  /// operator (or entity) art avatar
  operatorAvatar('opicon'),

  /// operator faction logo
  operatorLogo('logo'),

  /// not specified
  other('other');

  final String folderLabel;
  const CacheType(this.folderLabel);
}

class LocalDataManager {
  /// local [Directory] of the app
  static late final Directory local;

  /// cache [Directory] to save cache media
  static late final Directory cache;

  /// download [Directory] (of Android) to save
  /// file into the download folder
  static late final Directory download;

  static Future<void> init() async {
    local = await getApplicationDocumentsDirectory();
    cache = await getApplicationCacheDirectory();

    // should modify this to add ios or other systems support
    var dirDownloadExists = await Directory("/storage/emulated/0/Download/").exists();
    download = dirDownloadExists
        ? Directory("/storage/emulated/0/Download/")
        : Directory("/storage/emulated/0/Downloads/");

    for (var server in Server.values) {
      final dirExist = await Directory(p.join(local.path, server.folderLabel)).exists();
      if (!dirExist) {
        await Directory(p.join(local.path, server.folderLabel)).create(recursive: true);
      }
    }
    for (var caches in CacheType.values) {
      final dirExist = await Directory(p.join(cache.path, caches.folderLabel)).exists();
      if (!dirExist) {
        await Directory(p.join(cache.path, caches.folderLabel)).create(recursive: true);
      }
    }
  }

  /// is just local path + server folder lol
  static String localpathServer(Server server) {
    return Directory(p.join(local.path, server.folderLabel)).path;
  }

  /// this will be the same for all servers¿?
  /// retrieves File, doesnt guarantees to exist
  /// if you need exist use [localCacheFileExist]
  static File localCacheFile(String filename, [CacheType? type]) {
    return File(p.join(cache.path, type?.folderLabel ?? CacheType.other.folderLabel, filename));
  }

  /// this will be the same for all servers¿?
  /// retrieves File, guarantees to exist
  /// if you dont need exist use [localCacheFile]
  static Future<File> localCacheFileExist(String filename, CacheType? type) async {
    final file = await File(p.join(cache.path, type?.folderLabel ?? 'other', filename)).create(
      recursive: true,
    );
    return file;
  }

  /// this will be the same for all servers¿?
  /// retrieves File, guarantees to exist, sync version of [localCacheFileExist]
  /// if you dont need exist use [localCacheFile]
  static File localCacheFileExistSync(String filename, CacheType? type) {
    final file = File(p.join(cache.path, type?.folderLabel ?? 'other', filename))
      ..createSync(
        recursive: true,
      );
    return file;
  }
}
