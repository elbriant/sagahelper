import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/routes/home_route.dart';
import 'package:sagahelper/routes/info_route.dart';
import 'package:sagahelper/routes/operators_route.dart';
import 'package:sagahelper/routes/settings_route.dart';
import 'package:sagahelper/routes/tools_route.dart';

class Skeleton extends StatefulWidget {
  final Widget? errorDisplay;
  const Skeleton({super.key, this.errorDisplay});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  final List _pages = const [
    HomePage(),
    OperatorsPage(),
    InfoPage(),
    ToolsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final uiProv = context.watch<UiProvider>();

    return MaterialApp(
      theme: uiProv.currentTheme.colorLight,
      darkTheme: uiProv.currentTheme.getDarkMode(uiProv.isUsingPureDark),
      themeMode: uiProv.themeMode,
      navigatorKey: NavigationService.navigatorKey,
      home: Scaffold(
        extendBody: true,
        body: Builder(
          builder: (context) {
            if (widget.errorDisplay != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: widget.errorDisplay!)),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.ease,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 2.0,
                    20,
                    2.0,
                  ),
                  height: settingsProv.showNotifier ? (MediaQuery.of(context).padding.top + 24) : 0,
                  color: Theme.of(context).colorScheme.primary,
                  constraints: BoxConstraints.loose(MediaQuery.sizeOf(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 3.0,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Text(
                          settingsProv.loadingString,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _pages[uiProv.currentHomePageIndx],
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: uiProv.useTranslucentUi == true
            ? const TranslucentWidget(
                sigma: 3,
                child: BottomNavBar(opacity: 0.5),
              )
            : const BottomNavBar(),
      ),
    );
  }
}

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
        context.select<UiProvider?, int>((uiProvider) => uiProvider?.currentHomePageIndx ?? 0);

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
