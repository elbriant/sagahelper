import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class HomeMainWidget extends StatelessWidget {
  const HomeMainWidget({
    super.key,
    required this.serverTime,
  });

  final DateTime serverTime;

  DateTime get utcResetTime => DateTime.timestamp().copyWith(hour: 11, minute: 0, second: 0);

  String getTimeUntilReset() {
    final now = DateTime.now();

    final Duration difference = utcResetTime.toLocal().difference(now).isNegative
        ? utcResetTime.toLocal().add(const Duration(days: 1)).difference(now)
        : utcResetTime.toLocal().difference(now);

    return difference.asRemainingTime();
  }

  @override
  Widget build(BuildContext context) {
    final compactMode = context.read<SettingsProvider>().homeCompactMode;
    final currentServer = context.read<SettingsProvider>().currentServerString;
    final hour12 = context.read<SettingsProvider>().homeHour12Format;

    final String localResetTime = hour12
        ? DateFormat('h:mm a').format(utcResetTime.toLocal())
        : DateFormat('HH:mm').format(utcResetTime.toLocal());

    final String serverCurrentTime = serverTime.formatHome();

    final String timeUntilReset = getTimeUntilReset();

    return SizedBox(
      height: !compactMode ? 150 : 75,
      child: Card.filled(
        color: Theme.of(context).colorScheme.secondaryContainer,
        elevation: 2,
        child: Column(
          children: [
            !compactMode
                ? Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Local Reset Time: \n$localResetTime',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Server: ${currentServer.toUpperCase()}\n$serverCurrentTime',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Time until reset: \n$timeUntilReset',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
