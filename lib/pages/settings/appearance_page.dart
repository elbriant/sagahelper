import 'package:flutter_riverpod/flutter_riverpod.dart';
// -------------------- Appearance Settings Page ------------------------------
import 'package:flutter/material.dart';
import 'package:sagahelper/components/dialog_box.dart';
import 'package:sagahelper/components/theme_preview.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/themes.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/providers/config_provider.dart';

class AppearanceSettings extends ConsumerWidget {
  const AppearanceSettings({super.key});

  void updateSetting(WidgetRef ref, ConfigKeys key, Object value) {
    ref.read(configProvider.notifier).updateSettings(key, value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: const SystemNavBar(),
      appBar: AppBar(
        flexibleSpace: ConditionalTranslucentWidget(
          conditional: config.useTranslucentUi,
          child: Container(
            color: config.useTranslucentUi ? Colors.transparent : null,
          ),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .surfaceContainer
            .withValues(alpha: config.useTranslucentUi ? 0.5 : 1),
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
                    config.themeMode,
                  },
                  onSelectionChanged: (newSelection) =>
                      updateSetting(ref, ConfigKeys.themeMode, newSelection.first),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<ThemePreview>.generate(
                      allCustomThemes.length,
                      (index) => ThemePreview(
                        selfIndex: index,
                        thisSelected: config.customThemeIndex == index,
                        previewedTheme: allCustomThemes[index],
                        inkWellChild: InkWell(
                          splashColor: allCustomThemes[index]
                              .fromBrightnessAndPureDark(
                                Theme.of(context).brightness,
                                config.usePureDarkTheme,
                              )
                              .splashColor,
                          highlightColor: allCustomThemes[index]
                              .fromBrightnessAndPureDark(
                                Theme.of(context).brightness,
                                config.usePureDarkTheme,
                              )
                              .highlightColor,
                          onTap: () => updateSetting(ref, ConfigKeys.customTheme, index),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (config.themeMode != ThemeMode.light)
            SwitchListTile(
              secondary: config.usePureDarkTheme
                  ? const Icon(Icons.remove_red_eye)
                  : const Icon(Icons.remove_red_eye_outlined),
              subtitle: const Text('makes everything more darker'),
              title: const Text('Pure dark mode'),
              value: config.usePureDarkTheme,
              onChanged: (state) => updateSetting(ref, ConfigKeys.usePureDarkTheme, state),
            ),
          SwitchListTile(
            secondary:
                config.useTranslucentUi ? const Icon(Icons.blur_on) : const Icon(Icons.blur_off),
            subtitle: const Text(
              'makes UI transparent and blurry (performance cost!)',
            ),
            title: const Text('Traslucent UI'),
            value: config.useTranslucentUi,
            onChanged: (state) => updateSetting(ref, ConfigKeys.useTranslucentUi, state),
          ),
          ListTile(
            title: const Text('Home settings'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.access_time),
            title: const Text('12-hour format'),
            value: config.homeHour12Format,
            onChanged: (state) => updateSetting(ref, ConfigKeys.homeHour12Format, state),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.date_range),
            title: const Text('Show server date'),
            value: config.homeShowDate,
            onChanged: (state) => updateSetting(ref, ConfigKeys.homeShowDate, state),
          ),
          SwitchListTile(
            title: const Text('Show seconds'),
            value: config.homeShowSeconds,
            onChanged: (state) => updateSetting(ref, ConfigKeys.homeShowSeconds, state),
          ),
          SwitchListTile(
            title: const Text('Compact mode'),
            value: config.homeCompactMode,
            onChanged: (state) => updateSetting(ref, ConfigKeys.homeCompactMode, state),
          ),
          ListTile(
            title: const Text('Display'),
            textColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: const Text('Classic dialog box color'),
            value: config.useClassicDialogBox,
            onChanged: (state) => updateSetting(ref, ConfigKeys.useClassicDialogBox, state),
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
