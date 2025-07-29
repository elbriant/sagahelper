// -------------------- Appearance Settings Page ------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/dialog_box.dart';
import 'package:sagahelper/components/theme_preview.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/themes.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});

  @override
  State<AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<AppearanceSettings> {
  void changeThemeWithIndex(int index) {
    if (context.read<UiProvider>().previewThemeIndexSelected == index) return;
    setState(() {
      context.read<UiProvider>().previewThemeSelected(index);
      context.read<UiProvider>().changeTheme(newTheme: allCustomThemesList[index]);
    });
  }

  void pureDarkChange(bool newState) {
    setState(() {
      context.read<UiProvider>().togglePureDark(newState);
    });
  }

  void traslucentChange(bool newState) {
    setState(() {
      context.read<UiProvider>().toggleTraslucentUi(newState);
    });
  }

  void changeHourFormat(bool newState) {
    setState(() {
      context.read<SettingsProvider>().setHourFormat(newState);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

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
            ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : null,
        title: const Text('Appearance'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Color scheme'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.auto_mode),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {
                    context.read<UiProvider>().themeMode,
                  },
                  onSelectionChanged: (newSelection) => setState(() {
                    context.read<UiProvider>().setThemeMode(newThemeMode: newSelection.first);
                  }),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<ThemePreview>.generate(
                      allCustomThemesList.length,
                      (index) => ThemePreview(
                        selfIndex: index,
                        thisSelected:
                            context.watch<UiProvider>().previewThemeIndexSelected == index,
                        previewedTheme: allCustomThemesList[index],
                        inkWellChild: InkWell(
                          splashColor: Theme.of(context).brightness == Brightness.light
                              ? (allCustomThemesList[index].colorLight.splashColor)
                              : (allCustomThemesList[index]
                                  .getDarkMode(
                                    context.read<UiProvider>().isUsingPureDark,
                                  )
                                  .splashColor),
                          highlightColor: Theme.of(context).brightness == Brightness.light
                              ? (allCustomThemesList[index].colorLight.highlightColor)
                              : (allCustomThemesList[index]
                                  .getDarkMode(
                                    context.read<UiProvider>().isUsingPureDark,
                                  )
                                  .highlightColor),
                          onTap: () => changeThemeWithIndex(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (context.watch<UiProvider>().themeMode != ThemeMode.light)
            SwitchListTile(
              secondary: context.read<UiProvider>().isUsingPureDark
                  ? const Icon(Icons.remove_red_eye)
                  : const Icon(Icons.remove_red_eye_outlined),
              subtitle: const Text('makes everything more darker'),
              title: const Text('Pure dark mode'),
              value: context.read<UiProvider>().isUsingPureDark,
              onChanged: (state) => pureDarkChange(state),
            ),
          SwitchListTile(
            secondary: context.read<UiProvider>().useTranslucentUi
                ? const Icon(Icons.blur_on)
                : const Icon(Icons.blur_off),
            subtitle: const Text(
              'makes UI transparent and blurry (performance cost!)',
            ),
            title: const Text('Traslucent UI'),
            value: context.read<UiProvider>().useTranslucentUi,
            onChanged: (state) => traslucentChange(state),
          ),
          ListTile(
            title: const Text('Home settings'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.access_time),
            title: const Text('12-hour format'),
            value: settings.homeHour12Format,
            onChanged: (state) => setState(() {
              context.read<SettingsProvider>().setHourFormat(state);
            }),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.date_range),
            title: const Text('Show server date'),
            value: settings.homeShowDate,
            onChanged: (state) => setState(() {
              context.read<SettingsProvider>().sethomeShowDate(state);
            }),
          ),
          SwitchListTile(
            title: const Text('Show seconds'),
            value: settings.homeShowSeconds,
            onChanged: (state) => setState(() {
              context.read<SettingsProvider>().sethomeShowSeconds(state);
            }),
          ),
          SwitchListTile(
            title: const Text('Compact mode'),
            value: settings.homeCompactMode,
            onChanged: (state) => setState(() {
              context.read<SettingsProvider>().sethomeCompactMode(state);
            }),
          ),
          ListTile(
            title: const Text('Display'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: const Text('Classic dialog box color'),
            value: !context.select<UiProvider, bool>((p) => p.combineWithTheme),
            onChanged: (state) => context.read<UiProvider>().setCombineWithTheme(!state),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: DialogBox(
                title: 'Dialog box',
                body: 'This is a dialog box example',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
