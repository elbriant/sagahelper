import 'package:flutter_riverpod/flutter_riverpod.dart';
// ---------------------- Data Management Page ----------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/snack_bar_service.dart';
import 'package:sagahelper/models/config/config_manager.dart';
import 'package:sagahelper/models/server_state.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/style_provider.dart';

class DataSettings extends ConsumerStatefulWidget {
  const DataSettings({super.key});

  @override
  ConsumerState<DataSettings> createState() => _DataSettingsState();
}

class _DataSettingsState extends ConsumerState<DataSettings> {
  @override
  void initState() {
    super.initState();

    Future(() {
      refreshServers();
    });
  }

  void refreshServers() async {
    for (Server server in Server.values) {
      ref.read(serverProvider(server).notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const ServerTile(server: Server.en),
            const Divider(),
            const ServerTile(server: Server.cn),
            const Divider(),
            const ServerTile(server: Server.jp),
            const Divider(),
            const ServerTile(server: Server.kr),
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

class ServerTile extends ConsumerWidget {
  const ServerTile({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverState = ref.watch(serverProvider(server));
    final currentServer = ref.watch(configProvider.select((p) => p.currentServer));
    final staticColors = ref.watch(styleProvider).colors;

    final String version = serverState.version ?? 'No version';
    final DataState state = serverState.state;
    final String? folderSize = serverState.folderSize;

    void changeServer(Server server) {
      ref.read(configProvider.notifier).updateSettings(ConfigKeys.currentServer, server);

      /// uncache so all server related files gets reloaded
      /// lobotomize the cacheProvider
      ref.invalidate(cacheProvider);
      // Navigator.of(context).pop();
    }

    void getUpdate(Server server, DataState state) {
      switch (state) {
        case DataState.unknown:
          SnackBarService.showSnackBar('Try to force a fetch');
          if (serverState.version != null) changeServer(server);
        case DataState.fetching:
          SnackBarService.showSnackBar('Checking lastest version');
          if (serverState.version != null) changeServer(server);
        case DataState.hasUpdate:
          SnackBarService.showSnackBar('starting to download last version');
          ref.read(serverProvider(server).notifier).downloadLastest();
        case DataState.upToDate:
          changeServer(server);
        case DataState.error:
          SnackBarService.showSnackBar(
            'Something went wrong, try fetching later',
            type: SnackBarType.failure,
          );
          if (serverState.version != null) changeServer(server);
        case DataState.downloading:
          SnackBarService.showSnackBar('Downloading server files');
      }
    }

    void deleteServer() async {
      if (state == DataState.downloading) return;
      ref.read(serverProvider(server).notifier).deleteServer();

      /// uncache so all server related files gets reloaded
      /// lobotomize the cacheProvider
      ref.invalidate(cacheProvider);
    }

    void forceFetch() async {
      ref.read(serverProvider(server).notifier).refresh();
    }

    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => forceFetch(),
            backgroundColor: staticColors.blue,
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
            backgroundColor: staticColors.red,
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
        subtitle: currentServer == server
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
          DataState.unknown => const Icon(Icons.question_mark),
          DataState.fetching => const Icon(Icons.sync),
        },
        onTap: () {
          getUpdate(server, state);
        },
      ),
    );
  }
}
