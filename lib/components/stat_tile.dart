import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/providers/style_provider.dart';
import 'package:styled_text/styled_text.dart';

class StatTile extends ConsumerWidget {
  const StatTile({super.key, required this.stat, required this.value, this.isBonus = false});
  final String stat;
  final String value;
  final bool isBonus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPercent = stat.contains(r'%');
    final bool isNegative = value.characters.first == r'-';
    final tags = ref.watch(styleProvider).tagsAsStats;

    return StyledText(
      text:
          '<icon-${stat.replaceAll(r' ', '')}/><color stat="${stat.replaceAll(' ', '')}">$stat</color>\n${isBonus ? '<bonusCol>${isBonus ? '<bonusCol>${isNegative ? '' : '+'}' : ''}' : ''}$value${isPercent ? '%' : ''}${isBonus ? '</bonusCol>' : ''}',
      tags: tags,
      style: const TextStyle(
        shadows: [Shadow(offset: Offset.zero, blurRadius: 1.0)],
      ),
      async: true,
    );
  }
}

class StatTileText extends ConsumerWidget {
  const StatTileText({super.key, required this.stat});
  final String stat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(styleProvider).tagsAsStats;

    return StyledText(
      text:
          '<icon-${stat.replaceAll(r' ', '')}/><color stat="${stat.replaceAll(' ', '')}">$stat</color>',
      tags: tags,
      style: const TextStyle(
        shadows: [Shadow(offset: Offset.zero, blurRadius: 1.0)],
      ),
      async: true,
    );
  }
}

class StatTileValue extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPercent = stat.contains(r'%');
    final bool isNegative = value.characters.first == r'-';
    final tags = ref.watch(styleProvider).tagsAsStats;

    return StyledText(
      text:
          '${isBonus ? '<bonusCol>${isNegative ? '' : '+'}' : ''}$value${isPercent ? '%' : ''}${isBonus ? '</bonusCol>' : ''}',
      tags: tags,
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
