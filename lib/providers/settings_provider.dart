import 'package:flutter/material.dart';
import 'package:sagahelper/global_data.dart';

List<String> serverList = ['en', 'cn', 'jp', 'kr', 'tw'];
List<String> displayList = ['avatar', 'portrait'];

class SettingsProvider extends ChangeNotifier {
  // Settings
  int currentServer = 0;
  bool homeHour12Format = false;
  bool homeShowDate = false;
  bool homeShowSeconds = false;
  bool homeCompactMode = false;

  // Operators Page Flags
  int _operatorSearchDelegate = 2;
  int _operatorDisplay = 0;

  SettingsProvider();

  //tempo
  bool isLoadingHome = false;
  void setIsLoadingHome (bool state) {
    isLoadingHome = state;
    updateNotifier();
  }
  bool isLoadingAsync = false;
  void setIsLoadingAsync (bool state) {
    isLoadingAsync = state;
    updateNotifier();
  }
  String loadingString = 'test: test';
  void setLoadingString (String string) {
    loadingString = string;
    notifyListeners();
  }
  
  bool showNotifier = false;
  void updateNotifier () {
    if (isLoadingAsync || isLoadingHome) { // here other optional loadings
      showNotifier = true;
    } else {
      showNotifier = false;
    }
    notifyListeners();
  }

  final _configs = LocalDataManager();

  writeDefaultValues () async {
    return await _configs.writeConfigMap({
      'currentServer' : 0,
      '_operatorSearchDelegate' : 2,
      '_operatorDisplay' : 0,
      'homeHour12Format' : false,
      'homeShowDate': false,
      'homeShowSeconds': false,
      'homeCompactMode': false,
    });
  }

  setDefaultValues () {
    currentServer = 0;
    _operatorSearchDelegate = 2;
    _operatorDisplay = 0;
    homeHour12Format = false;
    homeShowDate = false;
    homeShowSeconds = false;
    homeCompactMode = false;
  }

  loadValues () async {
    return {
      'currentServer' : await _configs.readConfig('currentServer'),
      '_operatorSearchDelegate' : await _configs.readConfig('_operatorSearchDelegate'),
      '_operatorDisplay' : await _configs.readConfig('_operatorDisplay'),
      'homeHour12Format' : await _configs.readConfig('homeHour12Format'),
      'homeShowDate': await _configs.readConfig('homeShowDate'),
      'homeShowSeconds': await _configs.readConfig('homeShowSeconds'),
      'homeCompactMode': await _configs.readConfig('homeCompactMode'),
    };
  }

  setValues (Map configs) {
    currentServer = configs['currentServer'];
    _operatorSearchDelegate = configs['_operatorSearchDelegate'];
    _operatorDisplay = configs['_operatorDisplay'];
    homeHour12Format = configs['homeHour12Format'];
    homeShowDate = configs['homeShowDate'];
    homeShowSeconds = configs['homeShowSeconds'];
    homeCompactMode = configs['homeCompactMode'];
  }

  String get currentServerString => serverList[currentServer];

  int get operatorSearchDelegate => _operatorSearchDelegate;

  set operatorSearchDelegate (value) {
    _operatorSearchDelegate = value;
    notifyListeners();
  }

  String getDisplayChipStr() => displayList[_operatorDisplay];

  bool getDisplayChip(String chip){
    return displayList.indexOf(chip) == _operatorDisplay;
  }

  void setDisplayChip (String chip) {
    if (displayList.indexOf(chip) != _operatorDisplay) {
      _operatorDisplay = displayList.indexOf(chip);
      notifyListeners();
    }
  }

  void writeOpPageSettings () async {
    await _configs.writeConfigMap({
      '_operatorSearchDelegate' : _operatorSearchDelegate,
      '_operatorDisplay' : _operatorDisplay,
    });
  }

  void changeServer (int server) async {
    currentServer = server;
    await _configs.writeConfigKey('currentServer', server);
    notifyListeners();
  }

  void setHourFormat (bool value) async {
    homeHour12Format = value;
    await _configs.writeConfigKey('homeHour12Format', value);
    notifyListeners();
  }

  void sethomeShowDate (bool value) async {
    homeShowDate = value;
    await _configs.writeConfigKey('homeShowDate', value);
    notifyListeners();
  }

  void sethomeShowSeconds (bool value) async {
    homeShowSeconds = value;
    await _configs.writeConfigKey('homeShowSeconds', value);
    notifyListeners();
  }

  void sethomeCompactMode (bool value) async {
    homeCompactMode = value;
    await _configs.writeConfigKey('homeCompactMode', value);
    notifyListeners();
  }

}