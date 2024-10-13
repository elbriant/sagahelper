import 'dart:async';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:intl/intl.dart';
import 'package:sagahelper/global_data.dart' show NavigationService, firstTimeCheck;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String serverTimeString;
  late String serverResetString;
  late String localTimeString;
  late String localResetString;
  late String timeUntilReset;
  late String orundumResetString;
  late Timer timer;

  @override
  void initState() {
    _getTime();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {checkServer();});
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('News'),
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.0, MediaQuery.paddingOf(context).top+AppBar().preferredSize.height+24.0, 24.0, MediaQuery.paddingOf(context).bottom+24.0),
          child: Column(
            children: [
              SizedBox(
                height: !settings.homeCompactMode ? 150 : 75,
                child: Card.filled(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  elevation: 2,
                  child: Column(
                    children: [
                      !settings.homeCompactMode ? Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Center(child: Text('Local Reset Time: \n$localResetString'))),
                            Expanded(child: Center(child: Text('Server: ${settings.currentServerString.toUpperCase()}\n$serverTimeString')))
                          ],
                        ),
                      ) : Container(),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Center(child: Text('Time until reset: \n$timeUntilReset'))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GlassContainer.clearGlass(
                height: 120,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(2.0),
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.40), Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [const Color(0xffff0000), Theme.of(context).colorScheme.primary.withOpacity(0.40)],
                  stops: const [0.25, 0.75],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                )
                ,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.asset('assets/orundum.webp', scale: 1.8, fit: BoxFit.none, width: double.maxFinite, alignment: const Alignment(-0.8, 0.2), colorBlendMode: BlendMode.modulate, color: Colors.white.withOpacity(0.7)),
                      Container(width: double.maxFinite, height: double.maxFinite, alignment: Alignment.center, decoration: BoxDecoration(boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.surface.withOpacity(0.4), spreadRadius: -20, blurStyle: BlurStyle.normal, blurRadius: 25)]), child: Text('Time until weekly orundum reset: \n$orundumResetString'))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 60, child: Center(child: Text('planning to add "open today" tab'),)),
              const SizedBox(height: 40),
              const SizedBox(height: 60, child: Center(child: Text('planning to add more...'),)),
            ]
          ),
        ),
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
    } else { // en
      serverDateTime = now.toUtc().subtract(const Duration(hours: 7)); // UTC-7 
    }

    final DateTime serverResetTime = serverDateTime.copyWith(hour: 4, minute: 0, second: 0);
    final DateTime orundumResetTime = serverDateTime.copyWith(hour: 4, minute: 0, second: 0).add(Duration(days: 1 - serverDateTime.weekday));
    
    DateTime localResetTime;
    DateTime localOrundumResetTime;
    if (cs == 'cn') {
      localResetTime = serverResetTime.subtract(const Duration(hours: 8)); // shanghai UTC+8
      localOrundumResetTime = orundumResetTime.subtract(const Duration(hours: 8));
    } else if (cs == 'jp') {
      localResetTime = serverResetTime.subtract(const Duration(hours: 9)); // tokyo UTC+9
      localOrundumResetTime = orundumResetTime.subtract(const Duration(hours: 9));
    } else { // en
      localResetTime = serverResetTime.add(const Duration(hours: 7)); // UTC-7 
      localOrundumResetTime = orundumResetTime.add(const Duration(hours: 7));
    }
    
    final Duration orundumResetTimeDiff = localOrundumResetTime.toLocal().difference(now).isNegative ? localOrundumResetTime.toLocal().add(const Duration(days: 7)).difference(now) : localOrundumResetTime.toLocal().difference(now);
    final Duration difference = localResetTime.toLocal().difference(now).isNegative ? localResetTime.toLocal().add(const Duration(days: 1)).difference(now) : localResetTime.toLocal().difference(now);
    
    setState(() {
      localTimeString = _formatDateTime(now);
      serverTimeString = _formatDateTime(serverDateTime);
      serverResetString = _formatDateTime(serverResetTime);
      localResetString = hour12 ? DateFormat('h:mm a').format(localResetTime.toLocal()) : DateFormat('HH:mm').format(localResetTime.toLocal()) ;
      timeUntilReset = _formatRemainingTime(difference);
      orundumResetString = _formatRemainingTime(orundumResetTimeDiff);
    });
  }

  checkServer() async {
    if (firstTimeCheck) return;
    
    firstTimeCheck = true;
    NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('checking gamedata...');
    NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingHome(true);
    await Future.delayed(const Duration(seconds: 1));
    bool hasAllFiles = await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().checkFiles(NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString);

    if (NavigationService.navigatorKey.currentContext!.read<ServerProvider>().versionOf(NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString) == 'unknown' || !hasAllFiles) {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('downloading gamedata...');
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().downloadLastest(NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString);
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingHome(false);
    } else {
      NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('checking gamedata updates...');
      bool lastAvailable = await NavigationService.navigatorKey.currentContext!.read<ServerProvider>().checkUpdateOf(NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServerString);
      if (lastAvailable) {
        // ask if update
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('there is an update...');
        await Future.delayed(const Duration(seconds: 2));
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingHome(false);
      } else {

        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setLoadingString('everything fine');
        await Future.delayed(const Duration(seconds: 2));
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().setIsLoadingHome(false);
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
}

