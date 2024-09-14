import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Extra'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.2),
        elevation: 0,
      ),
      body: const Center(
        child: Text('test2'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}