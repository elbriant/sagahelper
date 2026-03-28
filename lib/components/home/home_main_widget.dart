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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          if (!compactMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Local Reset Time:\n',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          TextSpan(
                            text: localResetTime,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Server: ',
                          ),
                          TextSpan(
                            text: currentServer.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\n$serverCurrentTime',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Time until reset:\n',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      TextSpan(
                        text: timeUntilReset,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
