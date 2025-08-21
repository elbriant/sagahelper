import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/config_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int?> onDestinationSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translucentUi = ref.watch(configProvider.select((p) => p.useTranslucentUi));

    final child = NavigationBar(
      backgroundColor:
          Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: translucentUi ? 0.5 : 1),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
          selectedIcon: Icon(Icons.home),
        ),
        NavigationDestination(
          icon: Icon(Icons.person_search_outlined),
          label: 'Operators',
          selectedIcon: Icon(Icons.person_search),
        ),
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          label: 'Extra',
          selectedIcon: Icon(Icons.library_books),
        ),
        NavigationDestination(
          icon: Icon(Icons.app_shortcut_outlined),
          label: 'Tools',
          selectedIcon: Icon(Icons.app_shortcut),
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_outlined),
          label: 'More',
          selectedIcon: Icon(Icons.more_horiz),
        ),
      ],
    );

    return translucentUi
        ? TranslucentWidget(
            sigma: 3,
            child: child,
          )
        : child;
  }
}
