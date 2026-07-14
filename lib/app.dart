import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sagahelper/components/skeleton/bottom_nav_bar.dart';
import 'package:sagahelper/components/skeleton/global_notifier.dart';
import 'package:sagahelper/core/navigation_service.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/routes/home_route.dart';
import 'package:sagahelper/routes/info_route.dart';
import 'package:sagahelper/routes/operators_route.dart';
import 'package:sagahelper/routes/settings_route.dart';
import 'package:sagahelper/routes/tools_route.dart';

final _router = GoRouter(
  navigatorKey: NavigationService.rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: NavigationService.navigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return Scaffold(
          extendBody: true,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const GlobalNotifier(),
              Expanded(
                child: child,
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) => const _InnerApp(),
        ),
      ],
    ),
  ],
);

class _InnerApp extends ConsumerStatefulWidget {
  const _InnerApp();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __InnerAppState();
}

class __InnerAppState extends ConsumerState<_InnerApp> {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(0, 0, 0, 0.01),
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        body: pages[currentDestinationIndex],
        bottomNavigationBar: BottomNavBar(
          selectedIndex: currentDestinationIndex,
          onDestinationSelected: onDestinationChanged,
        ),
      ),
    );
  }
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(configProvider.select((p) => p.customTheme));
    final pureDark = ref.watch(configProvider.select((p) => p.usePureDarkTheme));
    final themeMode = ref.watch(configProvider.select((p) => p.themeMode));

    return MaterialApp.router(
      theme: currentTheme.themeLight,
      darkTheme: currentTheme.getDarkMode(pureDark),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
