import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'package:intl/intl.dart';
import 'package:sagahelper/global_data.dart'
    show NavigationService, firstTimeCheck, checkForUpdatesFlag;
import 'package:http/http.dart' as http;
import 'package:sagahelper/utils/misc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String serverTimeString;
  late String serverResetString;
  late DateTime serverCurrentDatetime;
  late String localTimeString;
  late String localResetString;
  late String timeUntilReset;
  late String orundumResetString;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _getTime();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkServer().then((_) async {
        List response = [];
        final server =
            NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;
        for (String filepath in ServerProvider.homeFiles) {
          response.add(
            await NavigationService.navigatorKey.currentContext!
                .read<ServerProvider>()
                .getFile(filepath, server),
          );
        }

        NavigationService.navigatorKey.currentContext!
            .read<CacheProvider>()
            .setStageTable(jsonDecode(response[0]) as Map<String, dynamic>);
      });
      checkForUpdates();
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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
        localResetTime: localResetString,
        serverTime: serverTimeString,
        timeUntilReset: timeUntilReset,
      ),
      const SizedBox(height: 40),
      HomeOrundum(
        orundumResetTime: orundumResetString,
      ),
      const SizedBox(height: 40),
      HomeUnlockedToday(
        currentDatetime: serverCurrentDatetime,
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

  void _getTime() {
    var cs = 'en';
    var hour12 = true;
    if (context.mounted) {
      cs = context.read<SettingsProvider>().currentServerString;
      hour12 = context.read<SettingsProvider>().homeHour12Format;
    }

    final DateTime now = DateTime.now();
    DateTime serverDateTime;
    if (cs == 'cn') {
      serverDateTime = now.toUtc().add(const Duration(hours: 8)); // shanghai UTC+8
    } else if (cs == 'jp') {
      serverDateTime = now.toUtc().add(const Duration(hours: 9)); // tokyo UTC+9
    } else {
      // en
      serverDateTime = now.toUtc().subtract(const Duration(hours: 7)); // UTC-7
    }

    final DateTime serverResetTime = serverDateTime.copyWith(hour: 4, minute: 0, second: 0);
    final DateTime orundumResetTime = serverDateTime
        .copyWith(hour: 4, minute: 0, second: 0)
        .add(Duration(days: 1 - serverDateTime.weekday));

    DateTime localResetTime;
    DateTime localOrundumResetTime;
    if (cs == 'cn') {
      localResetTime = serverResetTime.subtract(const Duration(hours: 8)); // shanghai UTC+8
      localOrundumResetTime = orundumResetTime.subtract(const Duration(hours: 8));
    } else if (cs == 'jp') {
      localResetTime = serverResetTime.subtract(const Duration(hours: 9)); // tokyo UTC+9
      localOrundumResetTime = orundumResetTime.subtract(const Duration(hours: 9));
    } else {
      // en
      localResetTime = serverResetTime.add(const Duration(hours: 7)); // UTC-7
      localOrundumResetTime = orundumResetTime.add(const Duration(hours: 7));
    }

    final Duration orundumResetTimeDiff = localOrundumResetTime.toLocal().difference(now).isNegative
        ? localOrundumResetTime.toLocal().add(const Duration(days: 7)).difference(now)
        : localOrundumResetTime.toLocal().difference(now);
    final Duration difference = localResetTime.toLocal().difference(now).isNegative
        ? localResetTime.toLocal().add(const Duration(days: 1)).difference(now)
        : localResetTime.toLocal().difference(now);

    setState(() {
      localTimeString = _formatDateTime(now);
      serverTimeString = _formatDateTime(serverDateTime);
      serverResetString = _formatDateTime(serverResetTime);
      serverCurrentDatetime = serverDateTime;
      localResetString = hour12
          ? DateFormat('h:mm a').format(localResetTime.toLocal())
          : DateFormat('HH:mm').format(localResetTime.toLocal());
      timeUntilReset = _formatRemainingTime(difference);
      orundumResetString = _formatRemainingTime(orundumResetTimeDiff);
    });
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
            .setLoadingString('There is a gamedata update...');
        showNotification(
          title: 'Gamedata update',
          body: 'Current version: $currentVersion Last version: $lastestVersion',
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

  String _formatDateTime(DateTime dateTime) {
    if (context.mounted) {
      List<String> result = [];
      final settings = context.read<SettingsProvider>();
      // date
      if (settings.homeShowDate) {
        result.add('EEE dd/MM');
      }

      //time
      if (settings.homeHour12Format) {
        if (settings.homeShowSeconds) {
          //12 hour and seconds
          result.add('hh:mm:ss a');
        } else {
          //12 hour
          result.add('h:mm a');
        }
      } else {
        if (settings.homeShowSeconds) {
          //24 hour and seconds
          result.add('HH:mm:ss');
        } else {
          //24 hour
          result.add('H:mm');
        }
      }
      return DateFormat(result.join(' ')).format(dateTime);
    }
    return '';
  }

  String _formatRemainingTime(Duration time) {
    if (context.mounted) {
      List<String> result = [];

      //days
      if (time.inDays > 1) {
        result.add('${time.inDays} days');
      } else if (time.inDays == 1) {
        result.add('${time.inDays} day');
      }

      // hours
      if (time.inHours.remainder(24) > 1) {
        result.add('${time.inHours.remainder(24)} hours');
      } else if (time.inHours.remainder(24) == 1) {
        result.add('${time.inHours.remainder(24)} hour');
      }
      // minutes
      if (time.inMinutes.remainder(60) > 1) {
        result.add('${time.inMinutes.remainder(60)} minutes');
      } else if (time.inMinutes.remainder(60) == 1) {
        result.add('${time.inMinutes.remainder(60)} minute');
      }

      // seconds
      if (context.read<SettingsProvider>().homeShowSeconds) {
        if (time.inSeconds.remainder(60) > 1) {
          result.add('${time.inSeconds.remainder(60)} seconds');
        } else if (time.inSeconds.remainder(60) == 1) {
          result.add('${time.inSeconds.remainder(60)} second');
        }
      }

      return result.join(' ');
    }
    return '';
  }

  Future<void> checkForUpdates() async {
    if (checkForUpdatesFlag) return;
    checkForUpdatesFlag = true;

    final response = await http
        .get(Uri.parse('https://api.github.com/repos/elbriant/sagahelper/releases/latest'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String githubVersion = (json['tag_name'] as String).substring(1);

      if (isVersionGreaterThan(githubVersion, version)) {
        showNotification(
          title: 'Update Available',
          body: 'New version ${json['tag_name']}, tap to open',
          payload: 'update-${json['html_url']}',
          channel: Channels.news,
        );
      }
    } else {
      // some error xd
    }
  }
}
