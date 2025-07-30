import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class BottomNavBar extends StatelessWidget {
  final double opacity;

  const BottomNavBar({
    super.key,
    this.opacity = 1.0,
  });

  void setNavBB(int index) {
    NavigationService.navigatorKey.currentContext!.read<UiProvider>().currentHomePageIndx = index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        context.select<UiProvider, int>((uiProvider) => uiProvider.currentHomePageIndx);

    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: opacity),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: setNavBB,
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
  }
}
