import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sagahelper/components/home_main_widget.dart';
import 'package:sagahelper/components/home_orundum.dart';
import 'package:sagahelper/components/home_unlocked_today.dart';
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
  late Timer timer;

  @override
  void initState() {
    super.initState();

    final cserver =
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;

    _getTime(cserver);
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime(cserver));

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
    final children = [
      HomeMainWidget(
        serverTime: serverCurrentDatetime,
      ),
      const SizedBox(height: 40),
      HomeOrundum(
        serverTime: serverCurrentDatetime,
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
            ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
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

  void _getTime(Servers server) {
    final DateTime now = DateTime.now();
    DateTime serverDateTime;

    if (server == Servers.cn) {
      serverDateTime = now.toUtc().add(const Duration(hours: 8)); // shanghai UTC+8
    } else if (server == Servers.en) {
      serverDateTime = now.toUtc().subtract(const Duration(hours: 7)); // UTC-7
    } else {
      // jp / kr
      serverDateTime = now.toUtc().add(const Duration(hours: 9)); // tokyo UTC+9
    }

    setState(() {
      serverCurrentDatetime = serverDateTime;
    });
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
