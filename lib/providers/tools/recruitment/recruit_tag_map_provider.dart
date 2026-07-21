import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/server_provider.dart';

class RecruitTagInfo {
  final int tagId;
  final String tagName;
  final String? tagCat;

  const RecruitTagInfo({
    required this.tagId,
    required this.tagName,
    this.tagCat,
  });
}

final recruitTagMapProvider = FutureProvider.autoDispose<Map<int, RecruitTagInfo>>((ref) async {
  final gachaTableString = await ref
      .watch(currentServerNotifierProvider.select((p) => p.tryGetFile(GameFile.gacha.path)));
  if (gachaTableString == null) throw Exception('Update Gamedata');

  final gachaJson = jsonDecode(gachaTableString);
  final gachaTags = gachaJson['gachaTags'] as List;

  const tagCategories = <int, String>{
    // Rarity
    28: 'Rarity',
    17: 'Rarity',
    14: 'Rarity',
    11: 'Rarity',
    // Position
    9: 'Position',
    10: 'Position',
    // Class
    8: 'Class',
    1: 'Class',
    3: 'Class',
    2: 'Class',
    6: 'Class',
    4: 'Class',
    5: 'Class',
    7: 'Class',
  };

  final result = <int, RecruitTagInfo>{};
  for (final tag in gachaTags) {
    final tagId = tag['tagId'] as int;
    if (tagId == 1012 || tagId == 1013) continue;
    final tagName = tag['tagName'] as String;
    final tagCat = tagCategories[tagId] ?? 'Others';

    result[tagId] = RecruitTagInfo(
      tagId: tagId,
      tagName: tagName,
      tagCat: tagCat,
    );
  }

  return result;
});
