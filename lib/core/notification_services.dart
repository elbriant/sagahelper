import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/server_provider.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/utils/misc.dart';
import 'package:sagahelper/core/global_data.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handling background notifications (app may be closed)
}

void notificationResponse(NotificationResponse notificationResponse) async {
  // handling notifications may need to enable showsUserInterface (app must be open)

  if (notificationResponse.payload != null) {
    if (notificationResponse.payload?.startsWith('update') ?? false) {
      openUrl(notificationResponse.payload!.split('-')[1]);
    }
    if (notificationResponse.payload == 'doUpdateServer') {
      final server =
          NavigationService.navigatorKey.currentContext!.read<SettingsProvider>().currentServer;
      NavigationService.navigatorKey.currentContext!
          .read<ServerProvider>()
          .setSingleServerState(server, DataState.downloading);
      ShowSnackBar.showSnackBar('starting to download last version');
      NavigationService.navigatorKey.currentContext!.read<ServerProvider>().downloadLastest(server);
    }
  }

  if (notificationResponse.actionId == 'cancelDownload') {
    flutterLocalNotificationsPlugin.cancel(notificationResponse.id!);
    await downloadsBackgroundCores[notificationResponse.id!.toString()]?.cancel();
    downloadsBackgroundCores.remove(notificationResponse.id.toString());
    usedId.remove(notificationResponse.id);
  }
}

Set<int> usedId = {};
int getUniqueId() {
  for (int id = 0; id <= 1000; id++) {
    if (usedId.contains(id)) {
      continue;
    } else {
      usedId.add(id);
      return id;
    }
  }
  return generateId();
}

int autoid = 1000;
int generateId() {
  autoid++;
  return autoid;
}

Future<void> initNotifications() async {
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_noti');

  final InitializationSettings initializationSettings = const InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  for (var notiGroup in notiChannelGroups) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannelGroup(notiGroup);
  }

  for (var notiDetail in notiChannels.values) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notiDetail);
  }
}

enum Channels { news, downloading, downloaded }

List notiChannelGroups = [
  const AndroidNotificationChannelGroup(
    'downloads',
    'Downloads',
    description: 'description',
  ),
];

Map<Channels, AndroidNotificationChannel> notiChannels = {
  Channels.downloading: const AndroidNotificationChannel(
    'downloading',
    'Download in progress',
    description: 'Downloading files',
    groupId: 'downloads',
    importance: Importance.low,
    playSound: false,
  ),
  Channels.downloaded: const AndroidNotificationChannel(
    'downloaded',
    'Downloaded',
    description: 'Downloaded files',
    groupId: 'downloads',
    importance: Importance.defaultImportance,
    playSound: true,
  ),
  Channels.news: const AndroidNotificationChannel(
    'new',
    'News',
    importance: Importance.defaultImportance,
    playSound: true,
  ),
};

Future<void> showNotification({
  int? id,
  required String title,
  required String body,
  String? payload,
  Channels? channel,
}) async {
  final NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channel != null ? notiChannels[channel]!.id : notiChannels[Channels.news]!.id,
      channel != null ? notiChannels[channel]!.name : notiChannels[Channels.news]!.name,
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    id ?? generateId(),
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}

Future<void> showDownloadNotification({
  required int id,
  required String title,
  required String body,
  int? progress,
  required bool ongoing,
  int? maxprogress,
  bool? indeterminate,
}) async {
  final NotificationDetails notificationDetails;

  if (ongoing) {
    notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        notiChannels[Channels.downloading]!.id,
        notiChannels[Channels.downloading]!.name,
        ongoing: true,
        autoCancel: false,
        actions: [
          const AndroidNotificationAction(
            'cancelDownload',
            'Cancel',
            showsUserInterface: true,
          ),
        ],
        category: AndroidNotificationCategory.progress,
        onlyAlertOnce: true,
        showProgress: true,
        progress: progress ?? 0,
        maxProgress: maxprogress ?? 100,
        indeterminate: indeterminate ?? false,
        priority: Priority.low,
      ),
    );
  } else {
    notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        notiChannels[Channels.downloaded]!.id,
        notiChannels[Channels.downloaded]!.name,
        ongoing: false,
        autoCancel: true,
        actions: [],
        priority: Priority.defaultPriority,
      ),
    );
  }
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
  );
}
