import 'dart:ui';
import 'package:docsprts/pages/home_page.dart';
import 'package:docsprts/pages/operators_page.dart';
import 'package:docsprts/pages/info_page.dart';
import 'package:docsprts/pages/settings_page.dart';
import 'package:docsprts/pages/tools_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:docsprts/themes.dart';
import 'package:docsprts/global_data.dart' as globals;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(0.1),
    ),
  );

  runApp( const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

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
    
    globals.currentTheme ??= CustomTheme(light: deepOrangeTheme.light, dark: deepOrangeTheme.dark, text: createTextTheme(context, "Noto Sans Hatran", "Noto Sans"));

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black
      ),
    );

    return MaterialApp(
      theme: globals.currentTheme?.light,
      darkTheme: globals.currentTheme?.getDarkMode(),
      themeMode: globals.themeMode,
      home: Scaffold(
        extendBody: true,
        body: _pages[_currentPageIndx],
        bottomNavigationBar: globals.useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: BottomNavBar(navigationBB: _navigationBB, currentPageIndx: _currentPageIndx, opacity: 0.5)) : BottomNavBar(navigationBB: _navigationBB, currentPageIndx: _currentPageIndx)
      ),
    );
  }
}

class TranslucentWidget extends StatelessWidget {
  final Widget child;
  final double sigma;
  const TranslucentWidget({super.key, required this.child, this.sigma = 3});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child
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
      backgroundColor: globals.themeMode == ThemeMode.light ?  globals.currentTheme!.light.colorScheme.surface.withOpacity(opacity) : globals.currentTheme!.getDarkMode().colorScheme.surface.withOpacity(opacity),
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: navigationBB,
      selectedIndex: currentPageIndx,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.person_search), label: 'Operators'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'More'),
        NavigationDestination(icon: Icon(Icons.app_shortcut), label: 'Tools'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}