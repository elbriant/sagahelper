import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/pages/home_page.dart';
import 'package:docsprts/pages/operators_page.dart';
import 'package:docsprts/pages/info_page.dart';
import 'package:docsprts/pages/settings_page.dart';
import 'package:docsprts/pages/tools_page.dart';
import 'package:docsprts/providers/cache_provider.dart';
import 'package:docsprts/providers/server_provider.dart';
import 'package:docsprts/providers/settings_provider.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/global_data.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemTheme.fallbackColor = const Color.fromARGB(255, 110, 110, 110);
  await SystemTheme.accentColor.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(0.1),
    ),
  );

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UiProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => ServerProvider()),
        ChangeNotifierProvider(create: (context) => CacheProvider())
      ],
      builder: (context, child) {
        if (loadedConfigs == true) {
          return const MainWidget();
        } else {
          return FutureBuilder(
            future: loadConfigs(), 
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                resetConfigs(context);
                return const ErrorScreen();
              } else if (snapshot.hasData) {
                var errorString = '';

                try {
                  //ui
                  context.read<UiProvider>().setValues((snapshot.data as Map)['ui_configs']);
                } catch (e) {
                  errorString += ' [ui error]';
                }

                try {
                  //settings
                  context.read<SettingsProvider>().setValues((snapshot.data as Map)['settings_configs']);
                } catch (e) {
                  errorString += ' [settings error]';
                }

                try {
                  //server
                  context.read<ServerProvider>().setValues((snapshot.data as Map)['server_configs']);
                } catch (e) {
                  context.read<ServerProvider>().writeDefaultValues();
                  context.read<ServerProvider>().setDefaultValues();
                }

                if (errorString != '') {
                  resetConfigs(context);
                  loadedConfigs = true;
                  return MainWidget(errorDisplay: Text('Data corrupted! $errorString'));
                }
                
                loadedConfigs = true;
                return const MainWidget();
              } else {
                return const LoadingScreen();
              }
            }
          );
        }
      },
    );
  }
}

resetConfigs(BuildContext context) async {
  context.read<UiProvider>().setDefaultValues();
  context.read<SettingsProvider>().setDefaultValues();

  final configs = LocalDataManager();
  await configs.resetConfig();
  await UiProvider().writeDefaultValues();
  await SettingsProvider().writeDefaultValues();
}

loadConfigs() async {
  final configs = LocalDataManager();
  var firstcheck = await configs.existConfig();

  if (firstcheck != true) {
    // default first configs
    await UiProvider().writeDefaultValues();
    await SettingsProvider().writeDefaultValues();
    await ServerProvider().writeDefaultValues();
  }

  var loadedConfigs = {
    'ui_configs' : await UiProvider().loadValues(),
    'settings_configs' : await SettingsProvider().loadValues(),
    'server_configs' : await ServerProvider().loadValues()
  };

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
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: context.watch<UiProvider>().currentTheme!.colorLight,
      darkTheme: context.watch<UiProvider>().currentTheme!.getDarkMode(context.read<UiProvider>().isUsingPureDark),
      themeMode: context.watch<UiProvider>().themeMode,
      navigatorKey: NavigationService.navigatorKey,
      home: Scaffold(
        extendBody: true,
        body: Builder(
          builder: (context){
            if (widget.errorDisplay != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: widget.errorDisplay!)));
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                context.watch<SettingsProvider>().showNotifier ? Container(padding: EdgeInsets.fromLTRB(0,MediaQuery.of(context).padding.top+2.0,0,2.0) , height: MediaQuery.of(context).padding.top+24, color: Theme.of(context).colorScheme.primary, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 12, width: 12, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary, strokeWidth: 3.0,)),
                    const SizedBox(width: 20),
                    Text(context.watch<SettingsProvider>().loadingString, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary))
                  ]
                )) : Container(),
                Expanded(child: _pages[context.watch<UiProvider>().currentHomePageIndx])
              ],
            );
          }
        ),
        bottomNavigationBar: context.watch<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: BottomNavBar(opacity: 0.5)) : BottomNavBar()
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final double opacity;

  const BottomNavBar ({
    super.key,
    this.opacity = 1.0,
  });

  void setNavBB (int index) {
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
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home', selectedIcon: Icon(Icons.home)),
        NavigationDestination(icon: Icon(Icons.person_search_outlined), label: 'Operators', selectedIcon: Icon(Icons.person_search)),
        NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Extra', selectedIcon: Icon(Icons.library_books)),
        NavigationDestination(icon: Icon(Icons.app_shortcut_outlined), label: 'Tools', selectedIcon: Icon(Icons.app_shortcut)),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'More', selectedIcon: Icon(Icons.settings)),
      ],
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent, brightness: MediaQuery.platformBrightnessOf(context))
      ),
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/gif/saga_loading.gif', width: 200, height: 200),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
              const SizedBox(height: 40),
              Text(context.watch<SettingsProvider>().loadingString)
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent, brightness: MediaQuery.platformBrightnessOf(context))
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/gif/saga_err.gif', width: 200, height: 200),
              const SizedBox(height: 40),
              Text('An error has ocurred, restart the app!', style: TextStyle(color: Theme.of(context).colorScheme.error),)
            ],
          ),
        ),
      ),
    );
  }
}