import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/skeleton/bottom_nav_bar.dart';
import 'package:sagahelper/components/skeleton/global_notifier.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/core/themes.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/routes/home_route.dart';
import 'package:sagahelper/routes/info_route.dart';
import 'package:sagahelper/routes/operators_route.dart';
import 'package:sagahelper/routes/settings_route.dart';
import 'package:sagahelper/routes/tools_route.dart';

class Skeleton extends StatelessWidget {
  final Widget? errorDisplay;
  const Skeleton({super.key, this.errorDisplay});

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.select<UiProvider, CustomTheme>((p) => p.currentTheme);
    final isPureDarkMode = context.select<UiProvider, bool>((p) => p.isUsingPureDark);
    final isTranslucentUi = context.select<UiProvider, bool>((p) => p.useTranslucentUi);
    final themeMode = context.select<UiProvider, ThemeMode>((p) => p.themeMode);
    final currentPageIndx = context.select<UiProvider, int>((p) => p.currentHomePageIndx);

    final currentServer = context.select<SettingsProvider, Servers>((p) => p.currentServer);

    final List pages = [
      HomePage(
        currentServer: currentServer,
      ),
      const OperatorsPage(),
      const InfoPage(),
      const ToolsPage(),
      const SettingsPage(),
    ];

    return MaterialApp(
      theme: currentTheme.colorLight,
      darkTheme: currentTheme.getDarkMode(isPureDarkMode),
      themeMode: themeMode,
      navigatorKey: NavigationService.navigatorKey,
      home: Scaffold(
        extendBody: true,
        body: Builder(
          builder: (context) {
            if (errorDisplay != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: errorDisplay!)),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const GlobalNotifier(),
                Expanded(
                  child: pages[currentPageIndx],
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: isTranslucentUi
            ? const TranslucentWidget(
                sigma: 3,
                child: BottomNavBar(opacity: 0.5),
              )
            : const BottomNavBar(),
      ),
    );
  }
}
