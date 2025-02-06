// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_text/styled_text.dart';

import 'package:sagahelper/providers/styles_provider.dart';

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.stat, required this.value, this.isBonus = false});
  final String stat;
  final String value;
  final bool isBonus;

  @override
  Widget build(BuildContext context) {
    final bool isPercent = stat.contains(r'%');

    return StyledText(
      text:
          '<icon-${stat.replaceAll(r' ', '')}/><color stat="${stat.replaceAll(' ', '')}">$stat</color>\n${isBonus ? '<bonusCol>+' : ''}$value${isPercent ? '%' : ''}${isBonus ? '</bonusCol>' : ''}',
      tags: context.read<StyleProvider>().tagsAsStats(context: context),
      style: const TextStyle(
        shadows: [Shadow(offset: Offset.zero, blurRadius: 1.0)],
      ),
      async: true,
    );
  }
}

class StatTileText extends StatelessWidget {
  const StatTileText({super.key, required this.stat});
  final String stat;

  @override
  Widget build(BuildContext context) {
    return StyledText(
      text:
          '<icon-${stat.replaceAll(r' ', '')}/><color stat="${stat.replaceAll(' ', '')}">$stat</color>',
      tags: context.read<StyleProvider>().tagsAsStats(context: context),
      style: const TextStyle(
        shadows: [Shadow(offset: Offset.zero, blurRadius: 1.0)],
      ),
      async: true,
    );
  }
}

class StatTileValue extends StatelessWidget {
  const StatTileValue({
    super.key,
    required this.stat,
    required this.value,
    required this.isBonus,
  });
  final String stat;
  final String value;
  final bool isBonus;

  @override
  Widget build(BuildContext context) {
    final bool isPercent = stat.contains(r'%');
    return StyledText(
      text:
          '${isBonus ? '<bonusCol>+' : ''}$value${isPercent ? '%' : ''}${isBonus ? '</bonusCol>' : ''}',
      tags: context.read<StyleProvider>().tagsAsStats(context: context),
      style: const TextStyle(
        shadows: [Shadow(offset: Offset.zero, blurRadius: 1.0)],
      ),
      async: true,
    );
  }
}

class StatTileList extends StatelessWidget {
  const StatTileList({
    super.key,
    required this.stat,
    required this.value,
    this.isBonus = false,
  });
  final String stat;
  final String value;
  final bool isBonus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1.0, 6.0, 6.0, 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatTileText(stat: stat),
          StatTileValue(stat: stat, value: value, isBonus: isBonus),
        ],
      ),
    );
  }
}
