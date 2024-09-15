import 'package:docsprts/components/theme_preview.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:docsprts/themes.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

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
          const DrawerHeader(child: Icon(Icons.settings, size: 42)), // saga gif maybe
          SwitchListTile(secondary: const Icon(Icons.wifi_off), title: const Text('Offline mode'), value: false, onChanged: (bools){}), 
          const Divider(), // top : quick switches / bot: more
          ListTile(title: const Text('Appearance'),leading: const Icon(Icons.color_lens), onTap: () {Navigator.push(context, MaterialPageRoute(allowSnapshotting: false, builder: (context) => const AppearanceSettings()));}, ),
          ListTile(title: const Text('Dunno'),leading: const Icon(Icons.device_unknown), onTap: () {}),
          const Divider(), // bot about and data
          ListTile(title: const Text('About'),leading: const Icon(Icons.info_outline), onTap: () {}),
        ],
      ),
    );
  }
}






// -------------------- Appearance Settings Page ------------------------------
class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {

  void changeThemeWithIndex (int index) {
    if (context.read<UiProvider>().previewThemeIndexSelected == index) return;
    setState(() {
      context.read<UiProvider>().previewThemeSelected(index);
      context.read<UiProvider>().changeTheme(newTheme: allCustomThemesList[index]);
    });
  }

  void pureDarkChange (bool newState) {
    setState(() {
      context.read<UiProvider>().togglePureDark(newState);
    });
  }

  void traslucentChange (bool newState) {
    setState(() {
      context.read<UiProvider>().toggleTraslucentUi(newState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance'), leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))),
      body: ListView(children: [
        ListTile(title: const Text('Color scheme'), textColor: Theme.of(context).colorScheme.primary),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SegmentedButton(segments: const [ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode), label: Text('System')), ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')), ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark'))], selected: {context.read<UiProvider>().themeMode}, onSelectionChanged: (newSelection) => setState((){context.read<UiProvider>().setThemeMode(newThemeMode: newSelection.first);})),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                height: 200,
                child: ListView (
                  padding: const EdgeInsets.all(8.0),
                  scrollDirection: Axis.horizontal,
                  children: List<ThemePreview>.generate(allCustomThemesList.length, 
                  (index) => ThemePreview (
                    selfIndex: index,
                    thisSelected: context.watch<UiProvider>().previewThemeIndexSelected == index,
                    previewedTheme: allCustomThemesList[index],
                    inkWellChild: InkWell(splashColor: Theme.of(context).brightness == Brightness.light? (allCustomThemesList[index].colorLight.splashColor) : (allCustomThemesList[index].getDarkMode(context.read<UiProvider>().isUsingPureDark).splashColor), highlightColor: Theme.of(context).brightness == Brightness.light? (allCustomThemesList[index].colorLight.highlightColor) : (allCustomThemesList[index].getDarkMode(context.read<UiProvider>().isUsingPureDark).highlightColor), onTap: () => changeThemeWithIndex(index)),
                    )
                  ),
                ),
              )
            ]
          )
        ),
        SwitchListTile(secondary: context.read<UiProvider>().isUsingPureDark ? const Icon(Icons.remove_red_eye) : const Icon(Icons.remove_red_eye_outlined), subtitle: const Text('makes everything more darker'), title: const Text('Pure dark mode'), value: context.read<UiProvider>().isUsingPureDark, onChanged: (state) => pureDarkChange(state)),
        SwitchListTile(secondary: context.read<UiProvider>().useTranslucentUi ? const Icon(Icons.blur_on) : const Icon(Icons.blur_off), subtitle: const Text('makes UI transparent and blurry (performance cost!)'), title: const Text('Traslucent UI'), value: context.read<UiProvider>().useTranslucentUi, onChanged: (state) => traslucentChange(state)),
      ]),
    );
  }
}