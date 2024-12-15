// ---------------------- Data Management Page ----------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

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
      extendBody: true,
      bottomNavigationBar: const SystemNavBar(),
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        title: const Text('Data Management'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('EN'),
              subtitle: Text(context.watch<ServerProvider>().enVersion),
              trailing: enHasUpdate == 'get'
                  ? null
                  : enHasUpdate == 'has'
                      ? const Icon(Icons.update)
                      : enHasUpdate == 'err'
                          ? const Icon(Icons.error)
                          : const Icon(Icons.done),
              onTap: () {
                getUpdate('en', enHasUpdate);
              },
            ),
            ListTile(
              title: const Text('CN'),
              subtitle: Text(context.watch<ServerProvider>().cnVersion),
              trailing: cnHasUpdate == 'get'
                  ? null
                  : cnHasUpdate == 'has'
                      ? const Icon(Icons.update)
                      : cnHasUpdate == 'err'
                          ? const Icon(Icons.error)
                          : const Icon(Icons.done),
              onTap: () {
                getUpdate('cn', cnHasUpdate);
              },
            ),
            ListTile(
              title: const Text('JP'),
              subtitle: Text(context.watch<ServerProvider>().jpVersion),
              trailing: jpHasUpdate == 'get'
                  ? null
                  : jpHasUpdate == 'has'
                      ? const Icon(Icons.update)
                      : jpHasUpdate == 'err'
                          ? const Icon(Icons.error)
                          : const Icon(Icons.done),
              onTap: () {
                getUpdate('jp', jpHasUpdate);
              },
            ),
          ],
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

      setState(() {
        if (server == 'en') enHasUpdate = status;
        if (server == 'cn') cnHasUpdate = status;
        if (server == 'jp') jpHasUpdate = status;
      });
    }
  }

  void getUpdate(String server, String status) {
    if (status == 'get') {
      ShowSnackBar.showSnackBar('checking last version');
    } else if (status == 'up') {
      ShowSnackBar.showSnackBar('already has the last version');
    } else if (status == 'has') {
      Navigator.pop(context);
      ShowSnackBar.showSnackBar('starting to download last version');
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().downloadLastest(server);
    } else if (status == 'err') {
      ShowSnackBar.showSnackBar(
        'something went wrong, try later',
        type: SnackBarType.failure,
      );
    }
  }
}
