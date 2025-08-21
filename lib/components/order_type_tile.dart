import 'package:flutter/material.dart';
import 'package:sagahelper/models/filters.dart';

class OperatorSortingTile extends StatelessWidget {
  const OperatorSortingTile({
    super.key,
    required this.operatorSorting,
    required this.label,
    required this.callback,
    required this.currentSortingType,
    required this.currentSortingReversed,
  });
  final OperatorSortingType operatorSorting;
  final String label;
  final ValueSetter<OperatorSortingType> callback;
  final OperatorSortingType currentSortingType;
  final bool currentSortingReversed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: currentSortingType == operatorSorting
          ? currentSortingReversed
              ? const Icon(Icons.arrow_upward)
              : const Icon(Icons.arrow_downward)
          : const Icon(
              Icons.arrow_downward,
              color: Colors.transparent,
            ),
      title: Text(label),
      onTap: () => callback(operatorSorting),
    );
  }
}
