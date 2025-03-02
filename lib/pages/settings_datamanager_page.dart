// ---------------------- Data Management Page ----------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

class DataSettings extends StatelessWidget {
  const DataSettings({super.key});

  void checkupdate() async {
    var servprov = NavigationService.navigatorKey.currentContext!.read<ServerProvider>();

    for (Servers server in Servers.values) {
      servprov.setSingleServerState(server, await servprov.getServerStatus(server));
      servprov.getFolderSize(server);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!serverFetchFlag) {
      serverFetchFlag = true;
      checkupdate();
    }

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
        title: const Text('Server & Data'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const ServerTile(server: Servers.en),
            const Divider(),
            const ServerTile(server: Servers.cn),
            const Divider(),
            const ServerTile(server: Servers.jp),
            const Divider(),
            const ServerTile(server: Servers.kr),
            const SizedBox(height: 20),
            Text(
              'Drag to left to delete server data, drag to right to force fetch last data',
              style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ServerTile extends StatelessWidget {
  const ServerTile({super.key, required this.server});
  final Servers server;

  @override
  Widget build(BuildContext context) {
    final String version = switch (server) {
      Servers.en => context.select<ServerProvider, String>(
          (prov) => prov.enVersion == '' ? 'No version' : prov.enVersion,
        ),
      Servers.cn => context.select<ServerProvider, String>(
          (prov) => prov.cnVersion == '' ? 'No version' : prov.cnVersion,
        ),
      Servers.jp => context.select<ServerProvider, String>(
          (prov) => prov.jpVersion == '' ? 'No version' : prov.jpVersion,
        ),
      Servers.kr => context.select<ServerProvider, String>(
          (prov) => prov.krVersion == '' ? 'No version' : prov.krVersion,
        ),
    };

    final DataState state = switch (server) {
      Servers.en => context.select<ServerProvider, DataState>((prov) => prov.enState),
      Servers.cn => context.select<ServerProvider, DataState>((prov) => prov.cnState),
      Servers.jp => context.select<ServerProvider, DataState>((prov) => prov.jpState),
      Servers.kr => context.select<ServerProvider, DataState>((prov) => prov.krState),
    };

    final Map<Servers, String> provFolderSize =
        context.select<ServerProvider, Map<Servers, String>>(
      (prov) => prov.folderSize,
    );

    final String? folderSize = provFolderSize.containsKey(server) ? provFolderSize[server] : null;

    final settingsServer = context.select<SettingsProvider, Servers>((prov) => prov.currentServer);

    void changeServer(Servers server) {
      context.read<SettingsProvider>().changeServer(server);
      Navigator.pop(context);
    }

    void getUpdate(Servers server, DataState state) {
      switch (state) {
        case DataState.fetching:
          ShowSnackBar.showSnackBar('checking last version');

        case DataState.hasUpdate:
          NavigationService.navigatorKey.currentContext!
              .read<ServerProvider>()
              .setSingleServerState(server, DataState.downloading);
          ShowSnackBar.showSnackBar('starting to download last version');
          NavigationService.navigatorKey.currentContext!
              .read<ServerProvider>()
              .downloadLastest(server);

        case DataState.upToDate:
          ShowSnackBar.showSnackBar('already has the last version');

        case DataState.error:
          ShowSnackBar.showSnackBar(
            'something went wrong, try later',
            type: SnackBarType.failure,
          );

        case DataState.downloading:
          ShowSnackBar.showSnackBar('downloading last version');
      }
    }

    void deleteServer() async {
      if (state == DataState.downloading) return;
      var servprov = NavigationService.navigatorKey.currentContext!.read<ServerProvider>();

      servprov.deleteServer(server).then((_) async {
        servprov.setSingleServerState(server, await servprov.getServerStatus(server));
      });

      NavigationService.navigatorKey.currentContext!.read<CacheProvider>().unCacheAll();
    }

    void forceFetch() async {
      var servprov = NavigationService.navigatorKey.currentContext!.read<ServerProvider>();

      servprov.setSingleServerState(server, DataState.fetching);
      servprov.setSingleServerState(server, await servprov.getServerStatus(server));
    }

    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => forceFetch(),
            backgroundColor: StaticColors.fromBrightness(context).blue,
            foregroundColor: Colors.white,
            icon: Icons.restart_alt,
            label: 'Fetch',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => deleteServer(),
            backgroundColor: StaticColors.fromBrightness(context).red,
            foregroundColor: Colors.white,
            icon: Icons.delete_forever,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          '${server.folderLabel.toUpperCase()} · $version ${folderSize != null ? '· $folderSize' : ''}',
        ),
        subtitle: settingsServer == server
            ? Text(
                'Selected',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
        trailing: switch (state) {
          DataState.hasUpdate => const Icon(Icons.update),
          DataState.upToDate => const Icon(Icons.done),
          DataState.error => const Icon(Icons.error),
          DataState.downloading => const Icon(Icons.downloading),
          _ => null
        },
        onTap: () {
          state == DataState.upToDate ? changeServer(server) : getUpdate(server, state);
        },
      ),
    );
  }
}
