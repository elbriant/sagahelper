import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';

class OpRouteFiltersAppareance extends StatelessWidget {
  const OpRouteFiltersAppareance({super.key});

  @override
  Widget build(BuildContext context) {
    final currentSearchDelegate =
        context.select<SettingsProvider, int>((prov) => prov.operatorSearchDelegate);
    final currentSearchDisplay =
        context.select<SettingsProvider, DisplayList>((prov) => prov.operatorDisplay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(title: Text('Cards')),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          child: Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Avatar'),
                selected: currentSearchDisplay == DisplayList.avatar,
                onSelected: (_) =>
                    context.read<SettingsProvider>().setDisplayChip(DisplayList.avatar),
              ),
              ChoiceChip(
                label: const Text('Portrait'),
                selected: currentSearchDisplay == DisplayList.portrait,
                onSelected: (_) =>
                    context.read<SettingsProvider>().setDisplayChip(DisplayList.portrait),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Expanded(
              flex: 3,
              child: Center(child: Text('Cards per row')),
            ),
            Expanded(
              flex: 7,
              child: Center(
                child: Slider(
                  min: 2,
                  max: 5,
                  divisions: 3,
                  value: currentSearchDelegate.toDouble(),
                  label: currentSearchDelegate.toString(),
                  onChanged: (value) {
                    context.read<SettingsProvider>().operatorSearchDelegate = value.round().toInt();
                  },
                  allowedInteraction: SliderInteraction.tapAndSlide,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
