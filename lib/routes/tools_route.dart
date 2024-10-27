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
      body: const Center(
        child: Text('tools be tooling'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}