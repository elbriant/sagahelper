// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:docsprts/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:intl/intl.dart';




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
  late Timer timer;

  @override
  void initState() {
    _getTime();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
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
              height: 150,
              child: Card.filled(
                child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Center(child: Text('Local Reset Time: \n$localResetString'))),
                            Expanded(child: Center(child: Text('Server: ${settings.currentServerString.toUpperCase()}\n$serverTimeString')))
                          ],
                        ),
                      ),
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

    DateTime localResetTime;
    if (cs == 'cn') {
      localResetTime = serverResetTime.subtract(const Duration(hours: 8)); // shanghai UTC+8
    } else if (cs == 'jp') {
      localResetTime = serverResetTime.subtract(const Duration(hours: 9)); // tokyo UTC+9
    } else { // en
      localResetTime = serverResetTime.add(const Duration(hours: 7)); // UTC-7 
    }

    final Duration difference = localResetTime.toLocal().difference(now).isNegative ? localResetTime.toLocal().add(const Duration(days: 1)).difference(now) : localResetTime.toLocal().difference(now);
    
    setState(() {
      localTimeString = _formatDateTime(now);
      serverTimeString = _formatDateTime(serverDateTime);
      serverResetString = _formatDateTime(serverResetTime);
      localResetString = hour12 ? DateFormat('h:mm a').format(localResetTime.toLocal()) : DateFormat('HH:mm').format(localResetTime.toLocal()) ;
      timeUntilReset = _formatRemainingTime(difference);
    });
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
      // hours
      if (time.inHours > 1) {
        result.add('${time.inHours} hours');
      } else if (time.inHours == 1) {
        result.add('${time.inHours} hour');
      }
      // minutes
      if (time.inMinutes.remainder(60) > 1) {
        result.add('${time.inMinutes.remainder(60)} minutes');
      } else if (time.inMinutes.remainder(60) == 1) {
        result.add('${time.inMinutes.remainder(60)} minute');
      }
      // seconds
      if (time.inSeconds.remainder(60) > 1) {
        result.add('${time.inSeconds.remainder(60)} seconds');
      } else if (time.inSeconds.remainder(60) == 1) {
        result.add('${time.inSeconds.remainder(60)} second');
      }

      return result.join(' ');
    }
    return '';
  }
}

