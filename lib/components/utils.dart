import 'package:url_launcher/url_launcher.dart';

extension StringExtension on String {
    String capitalize() {
      // ignore: unnecessary_this
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}

Future<void> openUrl(String urlStr, {LaunchMode mode = LaunchMode.externalApplication}) async {
  final Uri uri = Uri.parse(urlStr);
  if (await canLaunchUrl(uri)){
    await launchUrl(uri, mode: mode);
  } else {
    throw Exception('Could not launch $uri');
  }
}

String githubEncode(String input) {
  return Uri.encodeFull(input).replaceAll('#', '%23');
}