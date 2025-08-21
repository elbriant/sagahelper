import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/components/skeleton/bottom_nav_bar.dart';
import 'package:sagahelper/components/skeleton/global_notifier.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/routes/home_route.dart';
import 'package:sagahelper/routes/info_route.dart';
import 'package:sagahelper/routes/operators_route.dart';
import 'package:sagahelper/routes/settings_route.dart';
import 'package:sagahelper/routes/tools_route.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int currentDestinationIndex = 0;

  final List pages = const [
    HomePage(),
    OperatorsPage(),
    InfoPage(),
    ToolsPage(),
    SettingsPage(),
  ];

  void onDestinationChanged(int? index) {
    setState(() {
      currentDestinationIndex = index ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(configProvider.select((p) => p.customTheme));
    final pureDark = ref.watch(configProvider.select((p) => p.usePureDarkTheme));
    final themeMode = ref.watch(configProvider.select((p) => p.themeMode));

    return MaterialApp(
      theme: currentTheme.themeLight,
      darkTheme: currentTheme.getDarkMode(pureDark),
      themeMode: themeMode,
      navigatorKey: NavigationService.navigatorKey,
      home: Scaffold(
        extendBody: true,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const GlobalNotifier(),
            Expanded(
              child: pages[currentDestinationIndex],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: currentDestinationIndex,
          onDestinationSelected: onDestinationChanged,
        ),
      ),
    );
  }
}
