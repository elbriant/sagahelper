import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/providers/config_provider.dart';

class SettingsSettings extends ConsumerStatefulWidget {
  const SettingsSettings({super.key});

  @override
  ConsumerState<SettingsSettings> createState() => _SettingsSettingsState();
}

class _SettingsSettingsState extends ConsumerState<SettingsSettings> {
  late final TextEditingController nicknameTextController;
  String editedNickname = '';

  @override
  void initState() {
    super.initState();
    final nickname = ref.read(configProvider).nickname;
    nicknameTextController = TextEditingController(
      text: nickname,
    );
    editedNickname = nickname ?? '';
    nicknameTextController.addListener(() {
      setState(() {
        editedNickname = nicknameTextController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String nickname = ref.watch(configProvider.select((p) => p.nickname)) ?? '';
    final translucent = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    final gamedataUpdates = ref.watch(configProvider.select((p) => p.checkGamedataUpdatesOnStart));
    final appUpdates = ref.watch(configProvider.select((p) => p.checkAppUpdatesOnStart));

    void changeNickname() {
      ref.read(configProvider.notifier).updateSettings(ConfigKeys.nickname, editedNickname);
    }

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
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Personalization'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          const ListTile(
            title: Text('Nickname'),
            subtitle: Text('Is used to replace "Doctor" on operator\u2019s dialogs'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nicknameTextController,
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp("[a-zA-Z]"), allow: true),
                    ],
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          nicknameTextController.clear();
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      ),
                      hintText: 'Doctor',
                      border: const OutlineInputBorder(),
                    ),
                    maxLength: 12,
                    onSubmitted: nickname != editedNickname ? (_) => changeNickname() : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    onPressed: nickname != editedNickname ? changeNickname : null,
                    icon: const Icon(Icons.save),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Updates'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            subtitle: const Text(
              'Check for gamedata updates on app start',
            ),
            title: const Text('Check Gamedata Updates'),
            value: gamedataUpdates,
            onChanged: (state) => ref
                .read(configProvider.notifier)
                .updateSettings(ConfigKeys.checkGamedataUpdatesOnStart, state),
          ),
          SwitchListTile(
            subtitle: const Text(
              'Check for app updates on app start',
            ),
            title: const Text('Check App Updates'),
            value: appUpdates,
            onChanged: (state) => ref
                .read(configProvider.notifier)
                .updateSettings(ConfigKeys.checkAppUpdatesOnStart, state),
          ),
        ],
      ),
    );
  }
}
