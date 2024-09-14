import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('News'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.2),
        elevation: 0,
      ),
      body: const Center(
        child: TestWidget(),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}


class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}