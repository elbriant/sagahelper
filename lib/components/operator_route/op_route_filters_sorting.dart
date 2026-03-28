import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/operator_sorting_tile.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/providers/config_provider.dart';

class OpRouteFiltersSorting extends ConsumerWidget {
  const OpRouteFiltersSorting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSortingType = ref.watch(configProvider.select((p) => p.operatorSortingType));
    final currentSortingReversed =
        ref.watch(configProvider.select((p) => p.useOperatorSortingReversed));

    void changeSortingType(OperatorSortingType newOrder) {
      if (currentSortingType == newOrder) {
        ref
            .read(configProvider.notifier)
            .updateSettings(ConfigKeys.useOperatorSortingReversed, !currentSortingReversed);
        return;
      }
      ref.read(configProvider.notifier)
        ..updateSettings(ConfigKeys.operatorSortingType, newOrder)
        ..updateSettings(ConfigKeys.useOperatorSortingReversed, false);
    }

    return Wrap(
      children: [
        OperatorSortingTile(
          label: 'Rarity',
          operatorSorting: OperatorSortingType.rarity,
          callback: changeSortingType,
          currentSortingType: currentSortingType,
          currentSortingReversed: currentSortingReversed,
        ),
        OperatorSortingTile(
          label: 'Alphabetical',
          operatorSorting: OperatorSortingType.alphabetical,
          callback: changeSortingType,
          currentSortingType: currentSortingType,
          currentSortingReversed: currentSortingReversed,
        ),
        OperatorSortingTile(
          label: 'Creation (kinda)',
          operatorSorting: OperatorSortingType.creation,
          callback: changeSortingType,
          currentSortingType: currentSortingType,
          currentSortingReversed: currentSortingReversed,
        ),
      ],
    );
  }
}
