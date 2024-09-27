import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/pages/home_page.dart';
import 'package:docsprts/pages/operators_page.dart';
import 'package:docsprts/pages/info_page.dart';
import 'package:docsprts/pages/settings_page.dart';
import 'package:docsprts/pages/tools_page.dart';
import 'package:docsprts/providers/settings_provider.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        ChangeNotifierProvider(create: (context) => UiProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
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
                }catch (e) {
                  errorString += ' [settings error]';
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
  }

  var loadedConfigs = {
    'ui_configs' : await UiProvider().loadValues(),
    'settings_configs' : await SettingsProvider().loadValues()
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
        NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Extra', selectedIcon: Icon(Icons.library_books)),
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
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
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