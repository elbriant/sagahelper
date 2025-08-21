import 'package:flutter/material.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagahelper/core/global_data.dart';

class SettingsProvider extends ChangeNotifier {
  bool operatorIsSearching = false;
  String operatorFilterString = '';
  Map<String, FilterDetail> operatorFilters = {};

  // ------ tempo
  bool isLoadingHome;
  void setIsLoadingHome(bool state) {
    isLoadingHome = state;
    updateNotifier();
  }

  bool isLoadingAsync;
  void setIsLoadingAsync(bool state) {
    isLoadingAsync = state;
    updateNotifier();
  }

  String loadingString;
  void setLoadingString(String string) {
    loadingString = string;
    notifyListeners();
  }

  bool showNotifier = false;
  void updateNotifier() {
    if (isLoadingAsync || isLoadingHome) {
      // here other optional loadings
      showNotifier = true;
    } else {
      showNotifier = false;
    }
    notifyListeners();
  }

  void toggleOperatorFilter(FilterTag tag) {
    Map<String, FilterDetail> result = Map.of(operatorFilters);
    if (result.containsKey(tag.id)) {
      if (result[tag.id]!.mode != FilterMode.blacklist) {
        result[tag.id] = FilterDetail(
          key: result[tag.id]!.key,
          mode: FilterMode.blacklist,
          type: result[tag.id]!.type,
        );
      } else {
        result.remove(tag.id);
      }
    } else {
      result[tag.id] = FilterDetail(key: tag.key, mode: FilterMode.whitelist, type: tag.type);
    }
    operatorFilters = result;
    notifyListeners();
  }

  void addOperatorFilter(FilterTag tag) {
    Map<String, FilterDetail> result = Map.of(operatorFilters);

    result[tag.id] = FilterDetail(key: tag.key, mode: FilterMode.whitelist, type: tag.type);

    operatorFilters = result;
    notifyListeners();
  }

  void clearOperatorFilters() {
    operatorFilters = {};
    notifyListeners();
  }
}
