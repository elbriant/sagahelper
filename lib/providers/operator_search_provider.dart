import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sagahelper/models/filters.dart' show FilterDetail, FilterTag, FilterMode;
import 'package:sagahelper/models/operator_search_data.dart';

final operatorSearchProvider =
    NotifierProvider.autoDispose<OperatorSearchNotifier, OperatorSearchData>(
  OperatorSearchNotifier.new,
);

class OperatorSearchNotifier extends Notifier<OperatorSearchData> {
  @override
  build() {
    return const OperatorSearchData();
  }

  void toggleOperatorFilter(FilterTag tag) {
    // TODO: test, this may not work as it may appear as "same" info, so doesnt reloads new data from the map

    Map<String, FilterDetail> newFilters = state.operatorFilters;
    if (newFilters.containsKey(tag.id)) {
      if (newFilters[tag.id]!.mode != FilterMode.blacklist) {
        newFilters[tag.id] = FilterDetail(
          key: newFilters[tag.id]!.key,
          mode: FilterMode.blacklist,
          type: newFilters[tag.id]!.type,
        );
      } else {
        newFilters.remove(tag.id);
      }
    } else {
      newFilters[tag.id] = FilterDetail(key: tag.key, mode: FilterMode.whitelist, type: tag.type);
    }

    state = state.copyWith(
      operatorFilters: newFilters,
    );
  }

  void addOperatorFilter(FilterTag tag) {
    // TODO: test, this may not work as it may appear as "same" info, so doesnt reloads new data from the map
    Map<String, FilterDetail> newFilters = state.operatorFilters;

    newFilters[tag.id] = FilterDetail(key: tag.key, mode: FilterMode.whitelist, type: tag.type);

    state = state.copyWith(
      operatorFilters: newFilters,
    );
  }

  void clearOperatorFilters() {
    state = state.copyWith(
      operatorFilters: {},
    );
  }
}
