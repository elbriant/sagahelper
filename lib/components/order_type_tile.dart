import 'package:flutter/material.dart';
import 'package:sagahelper/models/filters.dart';

class OrderTypeTile extends StatelessWidget {
  const OrderTypeTile({
    super.key,
    required this.orderType,
    required this.label,
    required this.callback,
    required this.currentSortingType,
    required this.currentSortingReversed,
  });
  final OrderType orderType;
  final String label;
  final ValueSetter<OrderType> callback;
  final OrderType currentSortingType;
  final bool currentSortingReversed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: currentSortingType == orderType
          ? currentSortingReversed
              ? const Icon(Icons.arrow_upward)
              : const Icon(Icons.arrow_downward)
          : const Icon(
              Icons.arrow_downward,
              color: Colors.transparent,
            ),
      title: Text(label),
      onTap: () => callback(orderType),
    );
  }
}
