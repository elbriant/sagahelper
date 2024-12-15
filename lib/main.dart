import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/notification_services.dart';
import 'package:sagahelper/pages/main_loaderror_page.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/routes/home_route.dart';
import 'package:sagahelper/routes/info_route.dart';
import 'package:sagahelper/routes/operators_route.dart';
import 'package:sagahelper/routes/settings_route.dart';
import 'package:sagahelper/routes/tools_route.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemTheme.fallbackColor = Colors.grey;
  await SystemTheme.accentColor.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(0, 0, 0, 0.01),
    ),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  bool hasError = false;
  Map configs = {};
  try {
    configs = await loadConfigs();
  } catch (e) {
    hasError = true;
  }

  await initNotifications();
  await SettingsProvider.sharedPreferencesInit();

  runApp(MyApp(configs: configs, hasError: hasError));
}

class MyApp extends StatefulWidget {
  final Map configs;
  final bool hasError;
  const MyApp({super.key, required this.configs, required this.hasError});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UiProvider.fromConfig(widget.configs),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider.fromConfig(widget.configs),
        ),
        ChangeNotifierProvider(
          create: (context) => ServerProvider.fromConfig(widget.configs),
        ),
        ChangeNotifierProvider(create: (context) => CacheProvider()),
        ChangeNotifierProvider(create: (context) => StyleProvider()),
      ],
      builder: (context, child) {
        if (loadedConfigs == true) {
          return const MainWidget();
        }
        if (widget.hasError) {
          LocalDataManager.resetConfig();
          return const ErrorScreen();
        }
        loadedConfigs = true;
        return const MainWidget();
      },
    );
  }
}

Future<Map<String, dynamic>> loadConfigs() async {
  var firstcheck = await LocalDataManager.existConfig();

  Map<String, dynamic> loadedConfigs = {};

  if (firstcheck) {
    loadedConfigs.addAll(await UiProvider.loadValues());
    loadedConfigs.addAll(await SettingsProvider.loadValues());
    loadedConfigs.addAll(await ServerProvider.loadValues());
  }

  return loadedConfigs;
}

class MainWidget extends StatefulWidget {
  final Widget? errorDisplay;
  const MainWidget({super.key, this.errorDisplay});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final List _pages = const [
    HomePage(),
    OperatorsPage(),
    InfoPage(),
    ToolsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: context.watch<UiProvider>().currentTheme.colorLight,
      darkTheme: context.watch<UiProvider>().currentTheme.getDarkMode(context.read<UiProvider>().isUsingPureDark),
      themeMode: context.watch<UiProvider>().themeMode,
      navigatorKey: NavigationService.navigatorKey,
      home: Scaffold(
        extendBody: true,
        body: Builder(
          builder: (context) {
            if (widget.errorDisplay != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: widget.errorDisplay!)),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                context.watch<SettingsProvider>().showNotifier
                    ? Container(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          MediaQuery.of(context).padding.top + 2.0,
                          0,
                          2.0,
                        ),
                        height: MediaQuery.of(context).padding.top + 24,
                        color: Theme.of(context).colorScheme.primary,
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
                            Text(
                              context.watch<SettingsProvider>().loadingString,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                Expanded(
                  child: _pages[context.watch<UiProvider>().currentHomePageIndx],
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: context.watch<UiProvider>().useTranslucentUi == true
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
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(opacity),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: setNavBB,
      selectedIndex: context.watch<UiProvider>().currentHomePageIndx,
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
          icon: Icon(Icons.settings_outlined),
          label: 'More',
          selectedIcon: Icon(Icons.settings),
        ),
      ],
    );
  }
}
