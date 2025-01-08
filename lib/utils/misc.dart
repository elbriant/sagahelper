import 'package:url_launcher/url_launcher.dart';

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
