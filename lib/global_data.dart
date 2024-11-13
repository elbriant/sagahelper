import 'dart:convert';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

 // ----------------- local data

Map<String, DownloaderCore> downloadsBackgroundCores = {};
bool loadedConfigs = false;
bool firstTimeCheck = false;
bool opThemed = false;



// ------------- constants 

// Avatar assets from yuanyan3060 repo
const String kAvatarRepo = 'https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/refs/heads/main/avatar';

// Assets from ArknightsAssets repo
const String kPortraitRepo = 'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/charportraits';
const String kArtRepo = 'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/characters';
const String kLogoRepo = 'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/camplogo';

// Voice Assets from Aceship's repo
const String kVoiceRepo = 'https://github.com/Aceship/Arknight-voices/raw/refs/heads/main';


// ---------- helper classes

enum SnackBarType {normal, success, failure, warning, custom}

class ShowSnackBar {
  static void showSnackBar(String? text, {SnackBarType type = SnackBarType.normal, SnackBar? snackbar}) {
    switch (type) {
      case SnackBarType.normal:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(text!)));
        break;
      case SnackBarType.success:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.done, color: Colors.green[700]),
                Text(text!)
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
                Icon(Icons.warning_amber, color: Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.error),
                const SizedBox(width: 10),
                Expanded(child: Text(text!, style: TextStyle(color: Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.onErrorContainer),))
              ],
            ),
            backgroundColor: Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.errorContainer,
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
                Text(text!)
              ],
            ),
            backgroundColor: Colors.amber[100],
          ),
        );
        break;
      case SnackBarType.custom:
        assert(snackbar != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(snackbar!);
        break;
    }
  }
}

class NavigationService { 
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class LocalDataManager {
  final String configPath = 'configs.txt';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get downloadPath async {
    String directory = "/storage/emulated/0/Download/";

    var dirDownloadExists = await Directory(directory).exists();
    if(dirDownloadExists){
      directory = "/storage/emulated/0/Download/";
    }else{
      directory = "/storage/emulated/0/Downloads/";
    }
    return directory;
  }

  Future<String> localpathServer (String server) async {
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

  Future<File> localFile (String filePath) async {
    final path = await _localPath;
    var dirExists = await File('$path/$filePath').exists();

    if (dirExists == true) {
      return File('$path/$filePath');
    } else {
      return File('$path/$filePath').create(recursive: true);
    }
  }

  writeConfigKey(String key, dynamic data) async {
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
    file.writeAsString(encoded);
  }

  Future<File> writeConfigMap(Map<String, dynamic> map) async {
    final file = await localFile(configPath);
    // read json
    final contents = await file.readAsString();

    var parsed = <String, dynamic>{};
    
    if (contents != '') {
      // decode json to map
      parsed = jsonDecode(contents) as Map<String, dynamic>;
    }   

    // save data in json
    map.forEach((key, value){
      parsed[key] = value;
    });

    // encode json 
    final encoded = jsonEncode(parsed);

    // Write json to the file
    return file.writeAsString(encoded);
  }

  Future<dynamic> readConfig(String key) async {
    try {
      final file = await localFile(configPath);
      
      // Read the file
      final contents = await file.readAsString();

      // decode json to map
      final parsed = jsonDecode(contents) as Map<String, dynamic>;

      return parsed[key];

    } catch (e) {
      // If encountering an error, return -1
      return -1;
    }
  }

  Future<bool> existConfig() async {
    final file = await localFile(configPath);
    // Read the file
    final contents = await file.readAsString();

    if (contents == '') {
      return false;
    } else {
      return true;
    }

  }

  Future<void> resetConfig() async {
    final file = await localFile(configPath);
    await file.writeAsString('');
  }
}