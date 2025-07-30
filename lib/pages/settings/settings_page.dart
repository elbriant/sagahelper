import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class SettingsSettings extends StatefulWidget {
  const SettingsSettings({super.key});

  @override
  State<SettingsSettings> createState() => _SettingsSettingsState();
}

class _SettingsSettingsState extends State<SettingsSettings> {
  late final TextEditingController nicknameTextController;
  String nicknameControllerText = '';

  @override
  void initState() {
    super.initState();
    nicknameTextController = TextEditingController(
      text: NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().nickname,
    );
    nicknameControllerText =
        NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().nickname ?? '';
    nicknameTextController.addListener(() {
      setState(() {
        nicknameControllerText = nicknameTextController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String nickname = context.select<SettingsProvider, String?>((p) => p.nickname) ?? '';

    void changeNickname() {
      context
          .read<SettingsProvider>()
          .changeNickname(nicknameControllerText == '' ? null : nicknameControllerText);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: const SystemNavBar(),
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi
            ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : null,
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
                    onSubmitted: (_) => changeNickname(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    onPressed: nickname != nicknameControllerText ? changeNickname : null,
                    icon: const Icon(Icons.save),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
