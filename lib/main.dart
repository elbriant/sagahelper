import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/pages/home_page.dart';
import 'package:docsprts/pages/operators_page.dart';
import 'package:docsprts/pages/info_page.dart';
import 'package:docsprts/pages/settings_page.dart';
import 'package:docsprts/pages/tools_page.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docsprts/themes.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/global_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (context) => UiProvider())
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
                try {
                  //settings
                  context.read<UiProvider>().currentTheme = allCustomThemesList[(snapshot.data as Map)['currentTheme']];
                  context.read<UiProvider>().themeMode = listAllThemeModes[(snapshot.data as Map)['themeMode']];
                  context.read<UiProvider>().isUsingPureDark = (snapshot.data as Map)['isUsingPureDark'];
                  context.read<UiProvider>().useTranslucentUi = (snapshot.data as Map)['useTranslucentUi'];
                  context.read<UiProvider>().previewThemeIndexSelected = (snapshot.data as Map)['previewThemeIndexSelected'];
                } catch (e) {
                  resetConfigs(context);
                  loadedConfigs = true;
                  return const MainWidget(errorDisplay: Text('Data corrupted!'));
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
  context.read<UiProvider>().currentTheme = allCustomThemesList[0];
  context.read<UiProvider>().themeMode = listAllThemeModes[0];
  context.read<UiProvider>().isUsingPureDark = false;
  context.read<UiProvider>().useTranslucentUi = false;
  context.read<UiProvider>().previewThemeIndexSelected = 0;

  final configs = LocalDataManager();
  await configs.resetConfig();
  await configs.writeConfigMap({
      'currentTheme': 0,
      'themeMode': 0,
      'isUsingPureDark': false,
      'useTranslucentUi': false,
      'previewThemeIndexSelected' : 0
  });
}

loadConfigs() async {
  final configs = LocalDataManager();

  var firstcheck = await configs.existConfig();

  if (firstcheck != true) {
    // default first configs
    await configs.writeConfigMap({
      'currentTheme': 0,
      'themeMode': 0,
      'isUsingPureDark': false,
      'useTranslucentUi': false,
      'previewThemeIndexSelected' : 0
    });
  }

  var loadedConfigs = {
    'currentTheme': await configs.readConfig('currentTheme'),
    'themeMode': await configs.readConfig('themeMode'),
    'isUsingPureDark': await configs.readConfig('isUsingPureDark'),
    'useTranslucentUi': await configs.readConfig('useTranslucentUi'),
    'previewThemeIndexSelected' : await configs.readConfig('previewThemeIndexSelected')
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
  void _navigationBB(int newIndx) {
    setState(() {
      _currentPageIndx = newIndx;
    });
  }

  int _currentPageIndx = 0;

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
      home: Scaffold(
        extendBody: true,
        body: Builder(
          builder: (context){
            if (widget.errorDisplay != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: widget.errorDisplay!)));
            }
            return _pages[_currentPageIndx];
          }
        ),
        bottomNavigationBar: context.watch<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: BottomNavBar(navigationBB: _navigationBB, currentPageIndx: _currentPageIndx, opacity: 0.5)) : BottomNavBar(navigationBB: _navigationBB, currentPageIndx: _currentPageIndx)
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final void Function(int) navigationBB;
  final int currentPageIndx;
  final double opacity;

  const BottomNavBar ({
    super.key,
    required this.navigationBB,
    required this.currentPageIndx,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(opacity),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: navigationBB,
      selectedIndex: currentPageIndx,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home', selectedIcon: Icon(Icons.home)),
        NavigationDestination(icon: Icon(Icons.person_search_outlined), label: 'Operators', selectedIcon: Icon(Icons.person_search)),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Extra', selectedIcon: Icon(Icons.receipt_long)),
        NavigationDestination(icon: Icon(Icons.app_shortcut_outlined), label: 'Tools', selectedIcon: Icon(Icons.app_shortcut)),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'More', selectedIcon: Icon(Icons.settings)),
      ],
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

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
              Image.asset('assets/gif/saga_loading.gif', width: 200, height: 200),
              const SizedBox(height: 40),
              const CircularProgressIndicator()
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