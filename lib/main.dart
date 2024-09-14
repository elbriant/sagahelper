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
        if (context.read<UiProvider>().currentTheme == null) context.read<UiProvider>().currentTheme = deepOrangeTheme;
        return  MaterialApp(
          theme: context.watch<UiProvider>().currentTheme!.colorLight,
          darkTheme: context.watch<UiProvider>().currentTheme!.getDarkMode(context.read<UiProvider>().isUsingPureDark),
          themeMode: context.watch<UiProvider>().themeMode,
          home: Scaffold(
            extendBody: true,
            body: _pages[_currentPageIndx],
            bottomNavigationBar: context.watch<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: BottomNavBar(navigationBB: _navigationBB, currentPageIndx: _currentPageIndx, opacity: 0.5)) : BottomNavBar(navigationBB: _navigationBB, currentPageIndx: _currentPageIndx)
          ),
        );
      },
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
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(opacity),
      elevation: 0,
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