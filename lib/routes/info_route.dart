import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Extra'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.2),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: SizedBox(
                    height: 220,
                    child: DrawerHeader(
                      child: Image.asset(
                        'assets/gif/saga_happy.gif',
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: '\n¯\\_(ツ)_/¯',
                ),
                TextSpan(
                  text: '\n Empty ( for now )',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 42,
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}
