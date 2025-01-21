import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:styled_text/styled_text.dart';

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
