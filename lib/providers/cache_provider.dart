import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/cache_data.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

List computeJsonDecode(List<String?> input) {
  List<Map?> result = [];

  for (final i in input) {
    result.add(i.isNotNull ? jsonDecode(i!) : i);
  }

  return result;
}

final cacheProvider = NotifierProvider<CacheNotifier, CacheData>(CacheNotifier.new);

class CacheNotifier extends Notifier<CacheData> {
  @override
  build() {
    return const CacheData();
  }

  Future<void> cacheHomeDependecies() async {
    List<String?> files = [];
    final server = ref.watch(configProvider).currentServer;

    for (String filepath in kHomeFiles) {
      files.add(
        await ref.watch(serverProvider(server).notifier).tryGetFile(filepath),
      );
    }

    final decoded = await compute(computeJsonDecode, files);

    state = state.copyWith(
      cachedStageTable: decoded[0] as Map<String, String>?,
    );
  }
}
