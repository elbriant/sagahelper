import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/app.dart';
import 'package:sagahelper/core/notification_service.dart';
import 'package:sagahelper/models/config/local_data_manager.dart' show LocalDataManager;
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/context_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_logs/flutter_logs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dynamic colors
  SystemTheme.fallbackColor = Colors.grey;
  await SystemTheme.accentColor.load();

  // normal system bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // dark color (transparent bugs sometimes)
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

  // app configurations
  final sharedPreferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  // local files
  await LocalDataManager.init();

  final providerContainer = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  final notificationService = providerContainer.read(notificationProvider);
  await notificationService.initNotifications();

  WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
    WidgetsBinding.instance.handlePlatformBrightnessChanged();
    providerContainer.read(contextProvider.notifier).update(
          ContextData(brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness),
        );
  };

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const App(),
    ),
  );
}
