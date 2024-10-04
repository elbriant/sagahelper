import 'package:docsprts/components/theme_preview.dart';
import 'package:docsprts/components/traslucent_ui.dart';
import 'package:docsprts/components/utils.dart' show openUrl;
import 'package:docsprts/global_data.dart';
import 'package:docsprts/providers/server_provider.dart';
import 'package:docsprts/providers/settings_provider.dart';
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
          SizedBox(height: 200, child: DrawerHeader(child: Image.asset('assets/gif/saga_more.gif', fit: BoxFit.fitHeight))), // i love seseren's gifs
          SwitchListTile(secondary: const Icon(Icons.wifi_off), title: const Text('Offline mode'), subtitle: const Text('WIP'), value: false, onChanged: (bools){}), 
          const Divider(), // top : quick switches / bot: more
          ListTile(title: const Text('Appearance'),leading: const Icon(Icons.color_lens), onTap: () {Navigator.push(context, MaterialPageRoute(allowSnapshotting: false, builder: (context) => const AppearanceSettings()));}),
          ListTile(title: const Text('Data'),leading: const Icon(Icons.data_usage), onTap: () {Navigator.push(context, MaterialPageRoute(allowSnapshotting: false, builder: (context) => const DataSettings()));}),
          ListTile(title: const Text('Language'), subtitle: const Text('WIP'), leading: const Icon(Icons.language), onTap: (){}),
          ListTile(title: const Text('Server'), leading: const Icon(Icons.settings_ethernet), onTap: () {Navigator.push(context, MaterialPageRoute(allowSnapshotting: false, builder: (context) => const ServerSettings()));}),
          const Divider(), // bot about and data
          ListTile(title: const Text('About'),leading: const Icon(Icons.info_outline), onTap: () {Navigator.push(context, MaterialPageRoute(allowSnapshotting: false, builder: (context) => const AboutSettings()));}),
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

  void changeHourFormat (bool newState) {
    setState(() {
      context.read<SettingsProvider>().setHourFormat(newState);
    });
  }

  @override
  Widget build(BuildContext context) {

    final settings = context.read<SettingsProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        title: const Text('Appearance'), leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))
      ),
      body: ListView(children: [
        ListTile(title: const Text('Color scheme'), textColor: Theme.of(context).colorScheme.primary),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SegmentedButton(segments: const [ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode), label: Text('System')), ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')), ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark'))], selected: {context.read<UiProvider>().themeMode}, onSelectionChanged: (newSelection) => setState((){context.read<UiProvider>().setThemeMode(newThemeMode: newSelection.first);})),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                padding: const EdgeInsets.all(8.0),
                height: 220,
                child: ListView (
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
        if (Theme.of(context).brightness == Brightness.dark) SwitchListTile(secondary: context.read<UiProvider>().isUsingPureDark ? const Icon(Icons.remove_red_eye) : const Icon(Icons.remove_red_eye_outlined), subtitle: const Text('makes everything more darker'), title: const Text('Pure dark mode'), value: context.read<UiProvider>().isUsingPureDark, onChanged: (state) => pureDarkChange(state)),
        SwitchListTile(secondary: context.read<UiProvider>().useTranslucentUi ? const Icon(Icons.blur_on) : const Icon(Icons.blur_off), subtitle: const Text('makes UI transparent and blurry (performance cost!)'), title: const Text('Traslucent UI'), value: context.read<UiProvider>().useTranslucentUi, onChanged: (state) => traslucentChange(state)),
        ListTile(title: const Text('Home settings'), textColor: Theme.of(context).colorScheme.primary),
        SwitchListTile(secondary: const Icon(Icons.access_time), title: const Text('12-hour format'), value: settings.homeHour12Format, onChanged: (state) => setState((){settings.setHourFormat(state);})),
        SwitchListTile(secondary: const Icon(Icons.date_range), title: const Text('Show server date'), value: settings.homeShowDate, onChanged: (state) => setState((){settings.sethomeShowDate(state);})),
        SwitchListTile(title: const Text('Show seconds'), value: settings.homeShowSeconds, onChanged: (state) => setState((){settings.sethomeShowSeconds(state);})),
        SwitchListTile(title: const Text('Compact mode'), value: settings.homeCompactMode, onChanged: (state) => setState((){settings.sethomeCompactMode(state);}))
      ]),
    );
  }
}

// ---------------------- Data Management Page ----------------------------------
class DataSettings extends StatefulWidget {
  const DataSettings({super.key});

  @override
  State<DataSettings> createState() => _DataSettingsState();
}

class _DataSettingsState extends State<DataSettings> {
  bool updateChecked = false;
  
  String enHasUpdate = 'get';
  String cnHasUpdate = 'get';
  String jpHasUpdate = 'get';

  @override
  Widget build(BuildContext context) {
    if (!updateChecked) checkupdate();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        title: const Text('Data Management'), leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(title: const Text('EN'), subtitle: Text(context.watch<ServerProvider>().enVersion), trailing: enHasUpdate == 'get' ? null : enHasUpdate == 'has' ? const Icon(Icons.update) : enHasUpdate == 'err' ? const Icon(Icons.error) : const Icon(Icons.done), onTap: (){getUpdate('en', enHasUpdate);}),
            ListTile(title: const Text('CN'), subtitle: Text(context.watch<ServerProvider>().cnVersion), trailing: cnHasUpdate == 'get' ? null : cnHasUpdate == 'has' ? const Icon(Icons.update) : cnHasUpdate == 'err' ? const Icon(Icons.error) : const Icon(Icons.done), onTap: (){getUpdate('cn', cnHasUpdate);}),
            ListTile(title: const Text('JP'), subtitle: Text(context.watch<ServerProvider>().jpVersion), trailing: jpHasUpdate == 'get' ? null : jpHasUpdate == 'has' ? const Icon(Icons.update) : jpHasUpdate == 'err' ? const Icon(Icons.error) : const Icon(Icons.done), onTap: (){getUpdate('jp', jpHasUpdate);}),
          ]
        ),
      ),
    );
  }

  void checkupdate() async {
    updateChecked = true;
    var servprov = NavigationService.navigatorKey.currentContext!.read<ServerProvider>();
    List<String> servers = ['en', 'cn', 'jp'];

    for (String server in servers) {
      String status;

      try {
        bool result = await servprov.checkUpdateOf(server);
        bool fileIntegrity = await servprov.checkFiles(server);

        if (result || !fileIntegrity) {
          status = 'has';
        } else {
          status = 'up';
        }
      } catch (e) {
        status = 'err';
      }

      setState((){
        if (server == 'en') enHasUpdate = status;
        if (server == 'cn') cnHasUpdate = status;
        if (server == 'jp') jpHasUpdate = status;
      });

    }
    
    
  }

  void getUpdate(String server, String status) {
    if (status == 'get') {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(const SnackBar(content: Text('checking last version')));
    } else if (status == 'up') {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(const SnackBar(content: Text('already has the last version')));
    } else if (status == 'has') {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(const SnackBar(content: Text('starting to download last version')));
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().downloadLastest(server);
    } else if (status == 'err') {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(const SnackBar(content: Text('something went wrong, try later')));
    }
    
    setState(() {
      updateChecked = false;
    });

  }

}

// -------------------------- Server Page ---------------------------------------
class ServerSettings extends StatelessWidget {
  const ServerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    void changedServer (int server) {
      settings.changeServer(server);
      Navigator.pop(context);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        title: const Text('Server'), leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(title: const Text('EN'), subtitle: settings.currentServerString == 'en' ? Text('Selected', style: TextStyle(color: Theme.of(context).colorScheme.primary)) : null, onTap: ()=>changedServer(serverList.indexOf('en'))),
            const Divider(),
            ListTile(title: const Text('CN'), subtitle: settings.currentServerString == 'cn' ? Text('Selected', style: TextStyle(color: Theme.of(context).colorScheme.primary)) : null, onTap: ()=>changedServer(serverList.indexOf('cn'))),
            const Divider(),
            ListTile(title: const Text('JP'), subtitle: settings.currentServerString == 'jp' ? Text('Selected', style: TextStyle(color: Theme.of(context).colorScheme.primary)) : null, onTap: ()=>changedServer(serverList.indexOf('jp'))),
            const Divider(),
            ListTile(title: const Text('KR', style: TextStyle(decoration: TextDecoration.lineThrough)), subtitle: Text('Not implemented yet', style: TextStyle(color: Theme.of(context).colorScheme.primary)), onTap: (){}),
            const Divider(),
            ListTile(title: const Text('TW', style: TextStyle(decoration: TextDecoration.lineThrough)), subtitle: Text('Not implemented yet', style: TextStyle(color: Theme.of(context).colorScheme.primary)), onTap: (){}),
          ]
        ),
      ),
    );
  }
}

// -------------------------- About Settings Page ----------------------------
class AboutSettings extends StatelessWidget {
  const AboutSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3,child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        title: const Text('About'), leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))
      ),
      body: ListView(
        children: [
          SizedBox(height: 220, child: DrawerHeader(child: Image.asset('assets/gif/saga_about.gif', alignment: Alignment.center, fit: BoxFit.cover))),
          const ListTile(title: Text('Version'), subtitle: Text('Beta 0.1')),
          const ListTile(title: Text('Check updates'), subtitle: Text('WIP')),
          const SizedBox(height: 16),
          Center(
            child: Text('Made with love ❤️', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => openUrl('https://github.com/elbriant/docsprts'), icon: Icon(Icons.code, size: 42, color: Theme.of(context).colorScheme.primary,))
            ],
          ),
        ],
      ),
    );
  }
}