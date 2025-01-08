import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class SettingsSettings extends StatelessWidget {
  const SettingsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: const SystemNavBar(),
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true
            ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
            : null,
        title: const Text('Server'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const Placeholder(),
    );
  }
}
