import 'dart:async';
import 'package:docsprts/providers/settings_provider.dart';
import 'package:flutter/material.dart';
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
      extendBody: true,
      appBar: AppBar(
        title: const Text('News'),
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('local! \n $localTimeString\n$localResetString \n\n server\n$serverTimeString\n$serverResetString\n\n$timeUntilReset')),
          ElevatedButton(onPressed: ()=> settings.changeServer(0), child: Text('en')),
          ElevatedButton(onPressed: ()=> settings.changeServer(1), child: Text('cn')),
          ElevatedButton(onPressed: ()=> settings.changeServer(2), child: Text('jp'))
        ],
      ),
    );
  }

  void _getTime() {

    var cs = 'en';
    if (context.mounted) {
      cs = context.read<SettingsProvider>().currentServerString;
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
      localResetString = _formatDateTime(localResetTime.toLocal());
      timeUntilReset = difference.toString();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM hh:mm:ss').add_jm().format(dateTime);
  }
}

