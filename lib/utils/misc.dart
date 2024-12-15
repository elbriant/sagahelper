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
