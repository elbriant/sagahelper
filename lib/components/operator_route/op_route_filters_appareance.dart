import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/models/config/types.dart';
import 'package:sagahelper/providers/config_provider.dart';

class OpRouteFiltersAppareance extends ConsumerWidget {
  const OpRouteFiltersAppareance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void setDisplayMode(OperatorDisplayMode mode) {
      ref.read(configProvider.notifier).updateSettings(ConfigKeys.operatorDisplayMode, mode);
    }

    final currentSearchDelegate = ref.watch(configProvider.select((p) => p.operatorSearchDelegate));
    final currentSearchDisplay = ref.watch(configProvider.select((p) => p.operatorDisplayMode));
    final showFavoriteBadge = ref.watch(configProvider.select((p) => p.showFavoriteBadge));

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
                selected: currentSearchDisplay == OperatorDisplayMode.avatar,
                onSelected: (_) => setDisplayMode(OperatorDisplayMode.avatar),
              ),
              ChoiceChip(
                label: const Text('Portrait'),
                selected: currentSearchDisplay == OperatorDisplayMode.portrait,
                onSelected: (_) => setDisplayMode(OperatorDisplayMode.portrait),
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
                  label: currentSearchDelegate.toStringAsFixed(0),
                  onChanged: (value) {
                    ref
                        .read(configProvider.notifier)
                        .updateSettings(ConfigKeys.operatorSearchDelegate, value.toInt());
                  },
                  allowedInteraction: SliderInteraction.tapAndSlide,
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Show favorite badge'),
          subtitle: const Text('Display heart icon on favorite operators'),
          value: showFavoriteBadge,
          onChanged: (value) {
            ref.read(configProvider.notifier).updateSettings(ConfigKeys.showFavoriteBadge, value);
          },
        ),
      ],
    );
  }
}
