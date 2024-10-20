import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sagahelper/components/utils.dart';
import 'package:sagahelper/global_data.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('$notificationResponse  background response');
}

void notificationResponse(NotificationResponse notificationResponse) async {
  print('$notificationResponse  normal response');

  if (notificationResponse.payload != null) {
    if (notificationResponse.payload == 'update') {
      openUrl('https://github.com/elbriant/sagahelper');
    }
  }
  
  if (notificationResponse.actionId == 'cancelDownload') {
    print('cancel');
    flutterLocalNotificationsPlugin.cancel(notificationResponse.id!);
    await downloadsBackgroundCores[notificationResponse.id!.toString()]?.cancel();
    downloadsBackgroundCores.remove(notificationResponse.id.toString());
    usedId.remove(notificationResponse.id);
  }
}

Set<int> usedId = {};
int getUniqueId() {
  for(int id = 0; id <= 1000; id++) {
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
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_saga');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground
  );

  for (var notiGroup in notiChannelGroups) {
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannelGroup(notiGroup);
  }
  
  
  for (var notiDetail in notiChannels.values) {
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notiDetail);
  }

}

enum Channels {news, downloading, downloaded}

List notiChannelGroups = [AndroidNotificationChannelGroup('downloads', 'Downloads', description: 'description')];

Map<Channels, AndroidNotificationChannel> notiChannels = {
  Channels.downloading : AndroidNotificationChannel(
    'downloading',
    'Download in progress',
    description: 'Downloading files',
    groupId: 'downloads',
    importance: Importance.low,
    playSound: false
  ),
  Channels.downloaded : AndroidNotificationChannel(
    'downloaded',
    'Downloaded',
    description: 'Downloaded files',
    groupId: 'downloads',
    importance: Importance.defaultImportance,
    playSound: true
  ),
  Channels.news : AndroidNotificationChannel(
    'new',
    'News',
    importance: Importance.defaultImportance,
    playSound: true
  ),
};

Future<void> showNotification({int? id, required String title, required String body, String? payload, Channels? channel}) async {
  final NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channel != null ? notiChannels[channel]!.id : notiChannels[Channels.news]!.id,
      channel != null ? notiChannels[channel]!.name : notiChannels[Channels.news]!.name,
    )
  );
  
  await flutterLocalNotificationsPlugin.show(id ?? generateId(), title, body, notificationDetails, payload: payload);
}

Future<void> showDownloadNotification({
    required int id,
    required String title,
    required String body,
    int? progress,
    required bool ongoing,
    int? maxprogress,
    bool? indeterminate
  }) async {
    final NotificationDetails notificationDetails;

    if (ongoing) {
      notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          notiChannels[Channels.downloading]!.id,
          notiChannels[Channels.downloading]!.name,
          ongoing: true,
          autoCancel: false,
          actions: [AndroidNotificationAction('cancelDownload', 'Cancel', showsUserInterface: true)],
          category: AndroidNotificationCategory.progress,
          onlyAlertOnce: true,
          showProgress: true,
          progress: progress ?? 0,
          maxProgress: maxprogress ?? 100,
          indeterminate: indeterminate ?? false,
          priority: Priority.low,
        )
      );
    } else {
      notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          notiChannels[Channels.downloaded]!.id,
          notiChannels[Channels.downloaded]!.name,
          ongoing: false,
          autoCancel: true,
          actions: [],
          priority: Priority.defaultPriority
        )
      );
    } 
  await flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
}