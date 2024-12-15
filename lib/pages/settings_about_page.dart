// -------------------------- About Settings Page ----------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/utils/misc.dart';

class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

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
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        title: const Text('About'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: DrawerHeader(
              child: Image.asset(
                'assets/gif/saga_about.gif',
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const ListTile(title: Text('Version'), subtitle: Text('Beta 0.1')),
          const ListTile(title: Text('Check updates'), subtitle: Text('WIP')),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Made with love ❤️',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => openUrl('https://github.com/elbriant/sagahelper'),
                icon: Icon(
                  Icons.code,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
