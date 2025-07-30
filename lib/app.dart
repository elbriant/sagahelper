import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/pages/main_loaderror_page.dart';
import 'package:sagahelper/pages/main_skeleton_page.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class App extends StatelessWidget {
  final Map configs;
  final Object? hasError;
  const App({super.key, required this.configs, required this.hasError});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UiProvider.fromConfig(configs),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider.fromConfig(configs),
        ),
        ChangeNotifierProvider(
          create: (context) => ServerProvider.fromConfig(configs),
        ),
        ChangeNotifierProvider(create: (context) => CacheProvider()),
        ChangeNotifierProvider(create: (context) => StyleProvider()),
      ],
      builder: (context, child) {
        if (hasError != null) {
          return ErrorScreen(error: hasError!);
        }
        return const Skeleton();
      },
    );
  }
}
