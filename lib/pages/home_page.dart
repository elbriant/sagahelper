import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/providers/ui_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('News'),
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        elevation: 0,
      ),
      body: const Center(
        child: Text('here will have news!'),
      ),
    );
  }
}

