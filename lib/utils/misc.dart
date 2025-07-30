import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:sagahelper/components/popup_dialog.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

Future<void> openUrl(
  String urlStr, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  final Uri uri = Uri.parse(urlStr);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: mode);
  } else {
    throw Exception('Could not launch $uri');
  }
}

bool isVersionGreaterThan(String newVersion, String currentVersion) {
  List<String> currentV = currentVersion.split(".");
  List<String> newV = newVersion.split(".");
  bool a = false;
  for (var i = 0; i <= 2; i++) {
    a = int.parse(newV[i]) > int.parse(currentV[i]);
    if (int.parse(newV[i]) != int.parse(currentV[i])) break;
  }
  return a;
}

enum UpdateStatus { upToDate, alertSended, failedToFetch }

/// returns [UpdateStatus.alertSended] if statusCode 200 and sended alert
/// returns [UpdateStatus.upToDate] if statusCode 200 but app its up to date
/// else returns [UpdateStatus.failedToFetch]
///
/// [onError] triggered when statusCode != 200
Future<UpdateStatus> fetchUpdateAndAlert({
  void Function(http.Response)? onError,
}) async {
  final response =
      await http.get(Uri.parse('https://api.github.com/repos/elbriant/sagahelper/releases/latest'));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String githubVersion = (json['tag_name'] as String).substring(1);

    if (isVersionGreaterThan(githubVersion, version)) {
      PopupDialog.appUpdateAlert(
        context: NavigationService.navigatorKey.currentContext!,
        label: json["name"],
        body: json["body"],
        updateUrl: json["html_url"],
        currentVersion: version,
        newVersion: githubVersion,
      );
      return UpdateStatus.alertSended;
    } else {
      return UpdateStatus.upToDate;
    }
  }
  onError?.call(response);
  return UpdateStatus.failedToFetch;
}
