import 'package:sagahelper/pages/settings/about_page.dart';
import 'package:sagahelper/pages/settings/appearance_page.dart';
import 'package:sagahelper/pages/settings/datamanager_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/pages/settings/settings_page.dart';
import 'package:sagahelper/providers/config_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final offlineMode = ref.watch(configProvider.select((p) => p.offlineMode));

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('More', style: TextStyle(fontSize: 24)),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              child: Image.asset(
                'assets/gif/saga_more.gif',
                fit: BoxFit.fitHeight,
              ),
            ),
          ), // i love seseren's gifs
          SwitchListTile(
            secondary: const Icon(Icons.wifi_off),
            title: const Text('Offline mode'),
            subtitle: const Text('Disable all network requests'),
            value: offlineMode,
            onChanged: (value) => ref
                .read(configProvider.notifier)
                .updateSettings(ConfigKeys.offlineMode, value),
          ),
          const Divider(), // top : quick switches / bot: more
          ListTile(
            title: const Text('Appearance'),
            leading: const Icon(Icons.color_lens),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  allowSnapshotting: false,
                  builder: (context) => const AppearanceSettings(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Server & Data'),
            leading: const Icon(Icons.settings_ethernet),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  allowSnapshotting: false,
                  builder: (context) => const DataSettings(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('WIP'),
            leading: const Icon(Icons.language),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  allowSnapshotting: false,
                  builder: (context) => const SettingsSettings(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  allowSnapshotting: false,
                  builder: (context) => const AboutSettings(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
