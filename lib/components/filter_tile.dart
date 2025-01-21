import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class FilterTile extends StatelessWidget {
  const FilterTile({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: ExpandablePanel(
          theme: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: Theme.of(context).colorScheme.onSurface,
          ),
          header: ListTile(title: Text(title)),
          collapsed: const SizedBox(
            height: 0,
          ),
          expanded: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
