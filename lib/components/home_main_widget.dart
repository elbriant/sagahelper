import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sagahelper/providers/settings_provider.dart';

class HomeMainWidget extends StatelessWidget {
  const HomeMainWidget({
    super.key,
    required this.localResetTime,
    required this.serverTime,
    required this.timeUntilReset,
  });

  final String localResetTime;
  final String serverTime;
  final String timeUntilReset;

  @override
  Widget build(BuildContext context) {
    final compactMode = context.read<SettingsProvider>().homeCompactMode;
    final currentServer = context.read<SettingsProvider>().currentServerString;

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
                              'Server: ${currentServer.toUpperCase()}\n$serverTime',
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
