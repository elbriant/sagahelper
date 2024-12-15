// -------------------------- Server Page ---------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class ServerSettings extends StatelessWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    void changedServer(int server) {
      settings.changeServer(server);
      Navigator.pop(context);
    }

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
        title: const Text('Server'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('EN'),
              subtitle: settings.currentServerString == 'en'
                  ? Text(
                      'Selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
              onTap: () => changedServer(serverList.indexOf('en')),
            ),
            const Divider(),
            ListTile(
              title: const Text('CN'),
              subtitle: settings.currentServerString == 'cn'
                  ? Text(
                      'Selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
              onTap: () => changedServer(serverList.indexOf('cn')),
            ),
            const Divider(),
            ListTile(
              title: const Text('JP'),
              subtitle: settings.currentServerString == 'jp'
                  ? Text(
                      'Selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
              onTap: () => changedServer(serverList.indexOf('jp')),
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'KR',
                style: TextStyle(decoration: TextDecoration.lineThrough),
              ),
              subtitle: Text(
                'Not implemented yet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'TW',
                style: TextStyle(decoration: TextDecoration.lineThrough),
              ),
              subtitle: Text(
                'Not implemented yet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
