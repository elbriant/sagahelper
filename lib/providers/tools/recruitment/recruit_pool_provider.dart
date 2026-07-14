import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/operator_list_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';

final recruitPoolProvider = FutureProvider.autoDispose<List<Operator>>((ref) async {
  final gachaTableString = await ref
      .watch(currentServerNotifierProvider.select((p) => p.tryGetFile(GameFile.gacha.path)));
  if (gachaTableString == null) throw Exception('Update Gamedata');
  final operatorList = await ref.watch(operatorListProvider.future);
  final gachaJson = jsonDecode(gachaTableString);

  // inverse map (Name: key)
  Map<String, String> nameMap = {};
  for (var op in operatorList) {
    nameMap[op.name.toLowerCase()] = op.id;
  }

  // name substitution for certain ops based on: akgcc (OP_NAME_SUBSTITUTIONS)
  Map<String, String> substitutions = {
    "justice knight": "'justice knight'",
    "サーマル-ex": "thrm-ex",
    "샤미르": "샤마르",
  };

  List<String> validKeys = [];

  // - Group 1: (?<!>\s)<@rc\.eml>([^,，]*?)<\/> -> green marked ops.
  // - Group 2: (?:\/\s*|\n\s*|\\n\s*)((?!-)[^\r\/>★]+?(?<!-))(?=\/|$) -> all the others.
  RegExp regex = RegExp(
    r'(?<!>\s)<@rc\.eml>([^,，]*?)<\/>|(?:\/\s*|\n\s*|\\n\s*)((?!-)[^\r\/>★]+?(?<!-))(?=\/|$)',
    caseSensitive: false,
    multiLine: true,
  );

  Iterable<RegExpMatch> matches = regex.allMatches(gachaJson["recruitDetail"]);

  for (RegExpMatch match in matches) {
    // if m[1] is not null, is an exclusive operator. else, we use m[2].
    String? opName = match.group(1) ?? match.group(2);

    if (opName != null) {
      opName = opName.trim().toLowerCase();

      // Aplicar las sustituciones de nombres si existen en el diccionario
      if (substitutions.containsKey(opName)) {
        opName = substitutions[opName]!;
      }

      // Buscar en el mapa y agregar el Key
      if (nameMap.containsKey(opName)) {
        validKeys.add(nameMap[opName]!);
      } else {
        // Sanity check 😆
        throw Exception("⚠️ not found: '$opName'");
      }
    }
  }

  // finally we return the ops in the pool
  final validOperators = operatorList.where((e) => validKeys.contains(e.id)).toList();

  validOperators.sort((a, b) => b.rarity.compareTo(a.rarity));

  return validOperators;
});
