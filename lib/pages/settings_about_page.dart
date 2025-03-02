// -------------------------- About Settings Page ----------------------------
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/notification_services.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/utils/misc.dart';
import 'package:http/http.dart' as http;

class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  void checkUpdates() async {
    final response = await http
        .get(Uri.parse('https://api.github.com/repos/elbriant/sagahelper/releases/latest'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String githubVersion = (json['tag_name'] as String).substring(1);

      if (isVersionGreaterThan(githubVersion, version)) {
        showNotification(
          title: 'Update Available',
          body: 'New version ${json['tag_name']}, tap to open',
          payload: 'update-${json['html_url']}',
          channel: Channels.news,
        );
      } else {
        ShowSnackBar.showSnackBar("Already have lastest version");
      }
    } else {
      ShowSnackBar.showSnackBar(
        "Couldn't check updates [${response.statusCode} : ${(jsonDecode(response.body) as Map<String, dynamic>)["message"]}]",
      );
    }
  }

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
          ListTile(
            title: const Text('Check updates'),
            subtitle: const Text('tap to check for updates'),
            onTap: checkUpdates,
          ),
          ListTile(
            title: const Text('Credits'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          const _Credits(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Made with love for Saga ❤️',
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

class _Credits extends StatelessWidget {
  const _Credits();

  @override
  Widget build(BuildContext context) {
    final creditsEntries = credits.entries.toList();

    return Column(
      children: List.generate(creditsEntries.length, (index) {
        return ListTile(
          title: Text(creditsEntries[index].key),
          subtitle: Text(creditsEntries[index].value["assets"]),
          onTap: () => openUrl(creditsEntries[index].value["link"]),
        );
      }),
    );
  }
}
