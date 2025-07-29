import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/order_type_tile.dart';
import 'package:sagahelper/models/filters.dart';
import 'package:sagahelper/providers/settings_provider.dart';

class OpRouteFiltersSorting extends StatelessWidget {
  const OpRouteFiltersSorting({super.key});

  @override
  Widget build(BuildContext context) {
    final currentSortingType =
        context.select<SettingsProvider, OrderType>((prov) => prov.sortingOrder);
    final currentSortingReversed =
        context.select<SettingsProvider, bool>((prov) => prov.sortingReversed);

    void changeSortingType(OrderType newOrder) {
      if (currentSortingType == newOrder) {
        context.read<SettingsProvider>().setSortingReverse(!currentSortingReversed);
        return;
      }
      context.read<SettingsProvider>().setSortingType(newOrder);
      context.read<SettingsProvider>().setSortingReverse(false);
    }

    return Wrap(
      children: [
        OrderTypeTile(
          label: 'Rarity',
          orderType: OrderType.rarity,
          callback: changeSortingType,
          currentSortingType: currentSortingType,
          currentSortingReversed: currentSortingReversed,
        ),
        OrderTypeTile(
          label: 'Alphabetical',
          orderType: OrderType.alphabetical,
          callback: changeSortingType,
          currentSortingType: currentSortingType,
          currentSortingReversed: currentSortingReversed,
        ),
        OrderTypeTile(
          label: 'Creation',
          orderType: OrderType.creation,
          callback: changeSortingType,
          currentSortingType: currentSortingType,
          currentSortingReversed: currentSortingReversed,
        ),
      ],
    );
  }
}
