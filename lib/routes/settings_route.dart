import 'package:sagahelper/pages/settings_about_page.dart';
import 'package:sagahelper/pages/settings_appearance_page.dart';
import 'package:sagahelper/pages/settings_datamanager_page.dart';
import 'package:sagahelper/pages/settings_server_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
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
            subtitle: const Text('WIP'),
            value: false,
            onChanged: (bools) {},
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
            title: const Text('Data'),
            leading: const Icon(Icons.data_usage),
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
          ListTile(
            title: const Text('Server'),
            leading: const Icon(Icons.settings_ethernet),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  allowSnapshotting: false,
                  builder: (context) => const ServerSettings(),
                ),
              );
            },
          ),
          const Divider(), // bot about and data
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
