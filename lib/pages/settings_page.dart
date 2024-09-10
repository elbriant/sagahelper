import 'package:flutter/material.dart';

import 'package:docsprts/global_data.dart' as globals;

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
        title: Text('Settings', style: TextStyle(fontSize: 24)),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.2),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          DrawerHeader(child: Icon(Icons.settings, size: 48)),
          ListTile(title: Text('dark'),leading: Icon(Icons.color_lens), onTap: () {},),
          ListTile(title: Text('light'),leading: Icon(Icons.color_lens), onTap: () {})
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    );
  }
}