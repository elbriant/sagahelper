import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/notification_services.dart';
import 'package:sagahelper/pages/main_loaderror_page.dart';
import 'package:sagahelper/pages/main_skeleton_page.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_logs/flutter_logs.dart';

// TODO context menu
// TODO entity viewer (card and popup)
// TODO Deep linking, ie: opening oproute with custom selected tag from op info

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

  //Initialize Logging
  await FlutterLogs.initLogs(
    logLevelsEnabled: [LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR, LogLevel.SEVERE],
    timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
    directoryStructure: DirectoryStructure.FOR_DATE,
    logTypesEnabled: ["device", "network", "errors"],
    logFileExtension: LogFileExtension.LOG,
    logsWriteDirectoryName: "MyLogs",
    logsExportDirectoryName: "MyLogs/Exported",
    debugFileOperations: true,
    isDebuggable: true,
    logsRetentionPeriodInDays: 14,
    zipsRetentionPeriodInDays: 3,
    autoDeleteZipOnExport: false,
    autoClearLogs: true,
    enabled: true,
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      FlutterError.presentError(details);
      FlutterLogs.logThis(
        tag: 'MyApp',
        subTag: 'Caught an exception.',
        logMessage: details.exceptionAsString(),
        level: LogLevel.ERROR,
      );
    }
  };
  if (kReleaseMode) {
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FlutterLogs.logThis(
        tag: 'MyApp',
        subTag: 'Caught an exception.',
        logMessage: '${error.toString()}\nStacktrace: ${stack.toString()} ',
        level: LogLevel.ERROR,
      );
      return true;
    };
  }

  await initNotifications();
  await SettingsProvider.sharedPreferencesInit();
  await LocalDataManager.initDirectories();

  Object? hasError;
  Map configs = {};
  try {
    configs = await loadConfigs();
  } catch (e) {
    hasError = e;
  }

  runApp(MyApp(configs: configs, hasError: hasError));
}

class MyApp extends StatefulWidget {
  final Map configs;
  final Object? hasError;
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
        if (widget.hasError != null) {
          return ErrorScreen(error: widget.hasError!);
        }
        return const Skeleton();
      },
    );
  }
}
