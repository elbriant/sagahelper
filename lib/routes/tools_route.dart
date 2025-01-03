import 'package:flutter/material.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Tools'),
        backgroundColor: Colors.transparent,
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
                        'assets/gif/saga_scream.gif',
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: '\n Soon ( hopefully )',
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
