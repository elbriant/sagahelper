import 'package:flutter_riverpod/flutter_riverpod.dart';
// -------------------------- About Settings Page ----------------------------

import 'package:flutter/material.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/core/snack_bar_service.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/utils/misc.dart';

class AboutSettings extends ConsumerWidget {
  const AboutSettings({super.key});

  void checkUpdates() async {
    final status = await fetchUpdateAndAlert(
      onError: (e) {
        SnackBarService.showSnackBar(
          "Couldn't check updates",
        );
      },
    );

    if (status == UpdateStatus.upToDate) {
      SnackBarService.showSnackBar("Already have lastest version");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translucent = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: const SystemNavBar(),
      appBar: AppBar(
        flexibleSpace: ConditionalTranslucentWidget(
          conditional: translucent,
          child: Container(
            color: translucent ? Colors.transparent : null,
          ),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: translucent ? 0.5 : 1),
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
          const ListTile(title: Text('Version'), subtitle: Text(appVersion)),
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
