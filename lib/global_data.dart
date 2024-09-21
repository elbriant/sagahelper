import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

bool loadedConfigs = false;

class LocalDataManager {
  final String configPath = 'configs.txt';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
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