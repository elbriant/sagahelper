import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class HomeMainWidget extends ConsumerWidget {
  const HomeMainWidget({
    super.key,
    required this.serverTime,
    required this.serverResetTime,
  });

  final DateTime serverTime;
  final DateTime serverResetTime;

  String getTimeUntilReset(bool showSeconds) {
    final now = DateTime.now();

    final Duration difference = serverResetTime.toLocal().difference(now).isNegative
        ? serverResetTime.toLocal().add(const Duration(days: 1)).difference(now)
        : serverResetTime.toLocal().difference(now);

    return difference.asRemainingTime(showSeconds);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(configProvider);
    final compactMode = settings.homeCompactMode;
    final currentServer = settings.currentServer.serverString;
    final showSeconds = settings.homeShowSeconds;

    final String localResetTime = settings.homeHour12Format
        ? DateFormat('h:mm a').format(serverResetTime.toLocal())
        : DateFormat('HH:mm').format(serverResetTime.toLocal());

    final String serverCurrentTime = serverTime.formatHome(settings);
    final String timeUntilReset = getTimeUntilReset(showSeconds);

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
