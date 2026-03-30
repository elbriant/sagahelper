import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/components/home/home_main_widget.dart';
import 'package:sagahelper/components/home/home_orundum.dart';
import 'package:sagahelper/components/home/home_unlocked_today.dart';
import 'package:sagahelper/core/notification_service.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/models/server_state.dart' show DataState;
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/global_data.dart' show flagFirstTimeCheck, flagCheckForAppUpdates;
import 'package:sagahelper/providers/tasker_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:sagahelper/utils/misc.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late DateTime serverCurrentDatetime;
  late Timer timer;
  late DateTime resetTime;

  @override
  void initState() {
    super.initState();

    _getServerTime();
    resetTime = getResetTime();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getServerTime());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkServer().then((_) {
        _cacheDependencies();
      });

      requestNotification();

      checkForUpdates();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _getServerTime() {
    final DateTime now = DateTime.timestamp();
    DateTime serverDateTime;

    switch (ref.read(configProvider).currentServer) {
      case Server.cn:
        serverDateTime = now.add(const Duration(hours: 8)); // shanghai UTC+8
      case Server.en:
        serverDateTime = now.subtract(const Duration(hours: 7)); // UTC-7
      default:
        // jp / kr
        serverDateTime = now.add(const Duration(hours: 9)); // tokyo UTC+9
    }

    // day changes on 4:00am on all servers, not when 12:00am
    if (serverDateTime.hour >= 0 && serverDateTime.hour < 4) {
      serverDateTime = serverDateTime.subtract(const Duration(days: 1));
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

    switch (ref.read(configProvider).currentServer) {
      case Server.cn:
        // 4 - 8 = -4
        serverDateTime = now.subtract(const Duration(hours: 4)); // shanghai UTC+8
      case Server.en:
        // 4 - (-7) = 11
        serverDateTime = now.add(const Duration(hours: 11)); // UTC-7
      default:
        // jp / kr
        // 4 - 9 = -5
        serverDateTime = now.subtract(const Duration(hours: 5)); // tokyo UTC+9
    }

    return serverDateTime;
  }

  void _cacheDependencies() async {
    if (ref.read(cacheProvider).cachedStageTable.isNotNull) {
      return;
    }
    ref.read(cacheProvider.notifier).cacheHomeDependecies();
  }

  void requestNotification() async {
    if (!ref.read(configProvider).homeNotificationRequestAccepted) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      final res = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      ref
          .read(configProvider.notifier)
          .updateSettings(ConfigKeys.homeNotificationRequestAccepted, res ?? false);
    }
  }

  Future<void> checkServer() async {
    final shouldCheckUpdate = ref.read(configProvider).checkGamedataUpdatesOnStart;
    if (flagFirstTimeCheck || !shouldCheckUpdate) return;
    flagFirstTimeCheck = true;

    final taskId = ref.read(taskerProvider.notifier).addTask('Checking gamedata...');
    await Future.delayed(const Duration(seconds: 1));
    final hasAllFiles = await ref.read(currentServerNotifierProvider).existFiles();

    final server = ref.read(currentServerStateProvider);

    if (server.version.isNull || !hasAllFiles) {
      ref.read(taskerProvider.notifier)
        ..updateTask(taskId, 'Downloading gamedata...')
        ..timedRemoveTask(taskId);
      await ref.read(currentServerNotifierProvider).downloadLastest();
    } else {
      ref.read(taskerProvider.notifier).updateTask(taskId, 'Checking gamedata updates...');
      await ref.read(currentServerNotifierProvider).refresh();
      bool lastAvailable = ref.read(currentServerStateProvider).state == DataState.hasUpdate;
      if (lastAvailable) {
        // ask if update
        final currentVersion = ref.read(currentServerStateProvider).version;
        final lastestVersion = await ref.read(currentServerNotifierProvider).fetchLastestVersion();

        ref.read(taskerProvider.notifier)
          ..updateTask(taskId, 'There is a game data update...')
          ..timedRemoveTask(taskId);
        ref.read(notificationProvider).showNotification(
              title: 'Game data update',
              body: 'Current version: $currentVersion / Last version: $lastestVersion',
              payload: NotificationPayloads.serverUpdate.payload,
            );
      } else {
        ref.read(taskerProvider.notifier)
          ..updateTask(taskId, 'All good! ≧◡≦')
          ..timedRemoveTask(taskId);
      }
    }
  }

  Future<void> checkForUpdates() async {
    final shouldCheckUpdate = ref.read(configProvider).checkAppUpdatesOnStart;
    if (flagCheckForAppUpdates || !shouldCheckUpdate) return;
    flagCheckForAppUpdates = true;
    fetchUpdateAndAlert();
  }

  @override
  Widget build(BuildContext context) {
    final translucentUi = ref.watch(configProvider.select((p) => p.useTranslucentUi));

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
        title: const Text('Home and News'),
        flexibleSpace: translucentUi
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: translucentUi
            ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : null,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16.0,
          MediaQuery.paddingOf(context).top + AppBar().preferredSize.height + 16.0,
          16.0,
          MediaQuery.paddingOf(context).bottom + 24.0,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}
