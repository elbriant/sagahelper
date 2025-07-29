import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sagahelper/components/home/home_main_widget.dart';
import 'package:sagahelper/components/home/home_orundum.dart';
import 'package:sagahelper/components/home/home_unlocked_today.dart';
import 'package:sagahelper/notification_services.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/global_data.dart'
    show NavigationService, firstTimeCheck, checkForUpdatesFlag;
import 'package:sagahelper/utils/misc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List computeJsonDecode(List<String?> input) {
  List<Map?> result = [];

  for (final i in input) {
    if (i == null) {
      result.add(null);
      continue;
    }

    result.add(jsonDecode(i));
  }

  return result;
}

class _HomePageState extends State<HomePage> {
  late DateTime serverCurrentDatetime;
  late Servers currentServer;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    currentServer =
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;

    _getTime();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkServer().then((_) {
        _cacheDependencies();
      });

      requestNotification();

      if (!checkForUpdatesFlag) {
        checkForUpdates();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetTime = getResetTime();

    final children = [
      HomeMainWidget(
        serverTime: serverCurrentDatetime,
        serverResetTime: resetTime,
      ),
      const SizedBox(height: 40),
      HomeOrundum(
        serverTime: serverCurrentDatetime,
        serverResetTime: resetTime,
      ),
      const SizedBox(height: 40),
      HomeUnlockedToday(
        serverTime: serverCurrentDatetime,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('News'),
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true
            ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : null,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          24.0,
          MediaQuery.paddingOf(context).top + AppBar().preferredSize.height + 24.0,
          24.0,
          MediaQuery.paddingOf(context).bottom + 24.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  void _getTime() {
    final DateTime now = DateTime.timestamp();
    DateTime serverDateTime;

    if (currentServer == Servers.cn) {
      serverDateTime = now.add(const Duration(hours: 8)); // shanghai UTC+8
    } else if (currentServer == Servers.en) {
      serverDateTime = now.subtract(const Duration(hours: 7)); // UTC-7
    } else {
      // jp / kr
      serverDateTime = now.add(const Duration(hours: 9)); // tokyo UTC+9
    }

    setState(() {
      serverCurrentDatetime = serverDateTime;
    });
  }

  /// basically utc +/- offset +/- server reset time (4:00am on all servers)
  DateTime getResetTime() {
    final DateTime now = DateTime.timestamp()
        .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
    DateTime serverDateTime;

    // formula to get reset time in utc is
    // 4 (server reset) - [server offset]

    if (currentServer == Servers.cn) {
      // 4 - 8 = -4
      serverDateTime = now.subtract(const Duration(hours: 4)); // shanghai UTC+8
    } else if (currentServer == Servers.en) {
      // 4 - (-7) = 11
      serverDateTime = now.add(const Duration(hours: 11)); // UTC-7
    } else {
      // jp / kr
      // 4 - 9 = -5
      serverDateTime = now.subtract(const Duration(hours: 5)); // tokyo UTC+9
    }

    return serverDateTime;
  }

  void _cacheDependencies() async {
    List<String?> files = [];
    final server =
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;

    for (String filepath in ServerProvider.homeFiles) {
      files.add(
        await NavigationService.navigatorKey.currentContext!
            .read<ServerProvider>()
            .tryGetFile(filepath, server),
      );
    }

    final decode = await compute(computeJsonDecode, files);

    NavigationService.navigatorKey.currentContext!
        .read<CacheProvider>()
        .setStageTable(decode[0] as Map<String, dynamic>?);
  }

  void requestNotification() async {
    if (!NavigationService.navigatorKey.currentContext!
        .read<SettingsProvider>()
        .prefs[PrefsFlags.homeNotificationRequest]) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      final res = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setAndSaveBoolPref(PrefsFlags.homeNotificationRequest, res ?? false);
    }
  }

  Future<void> checkServer() async {
    if (firstTimeCheck) return;

    firstTimeCheck = true;

    NavigationService.navigatorKey.currentContext!
        .read<SettingsProvider>()
        .setLoadingString('checking gamedata...');

    NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingHome(true);

    await Future.delayed(const Duration(seconds: 1));

    bool hasAllFiles =
        await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().checkAllFiles(
              NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer,
            );

    if (NavigationService.navigatorKey.currentContext!.read<ServerProvider>().versionOf(
                  NavigationService.navigatorKey.currentContext!
                      .read<SettingsProvider>()
                      .currentServer,
                ) ==
            '' ||
        !hasAllFiles) {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('downloading gamedata...');
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().downloadLastest(
            NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer,
          );
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setIsLoadingHome(false);
    } else {
      NavigationService.navigatorKey.currentContext!
          .read<SettingsProvider>()
          .setLoadingString('checking gamedata updates...');
      bool lastAvailable = await NavigationService.navigatorKey.currentContext!
          .read<ServerProvider>()
          .checkUpdateOf(
            NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer,
          );
      if (lastAvailable) {
        // ask if update

        final currentVersion = NavigationService.navigatorKey.currentContext!
            .read<ServerProvider>()
            .versionOf(
              NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer,
            );
        final lastestVersion = await NavigationService.navigatorKey.currentContext!
            .read<ServerProvider>()
            .fetchLastestVersion(
              NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer,
            );

        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setLoadingString('There is a game data update...');
        showNotification(
          title: 'Game data update',
          body: 'Current version: $currentVersion / Last version: $lastestVersion',
          payload: 'doUpdateServer',
        );
        await Future.delayed(const Duration(seconds: 3));
        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setIsLoadingHome(false);
      } else {
        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setLoadingString('All good!');
        await Future.delayed(const Duration(seconds: 2));
        NavigationService.navigatorKey.currentContext!
            .read<SettingsProvider>()
            .setIsLoadingHome(false);
      }
    }
  }

  Future<void> checkForUpdates() async {
    checkForUpdatesFlag = true;
    fetchUpdateAndAlert();
  }
}
