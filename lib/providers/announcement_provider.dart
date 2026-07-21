import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sagahelper/models/announcement.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/connectivity_provider.dart';
import 'package:sagahelper/providers/server_provider.dart';

const Map<Server, String> _networkConfigUrls = {
  Server.en: 'https://ak-conf.arknights.global/config/prod/official/network_config',
  Server.jp: 'https://ak-conf.arknights.jp/config/prod/official/network_config',
  Server.kr: 'https://ak-conf.arknights.kr/config/prod/official/network_config',
  Server.cn: 'https://ak-conf.hypergryph.com/config/prod/official/network_config',
  Server.tw: 'https://ak-conf-tw.gryphline.com/config/prod/official/network_config',
};

const Map<String, String> _defaultHeaders = {
  'Content-Type': 'application/json',
  'X-Unity-Version': '2017.4.39f1',
  'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 11; KB2000 Build/RP1A.201005.001)',
  'Connection': 'Keep-Alive',
};

Future<String?> _fetchAnnouncementBaseUrl(Server server) async {
  final configUrl = _networkConfigUrls[server];
  if (configUrl == null) return null;

  try {
    final response = await http.get(
      Uri.parse(configUrl),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    final contentStr = data['content'] as String?;
    if (contentStr == null) return null;

    final content = json.decode(contentStr) as Map<String, dynamic>;
    final funcVer = content['funcVer'] as String?;
    if (funcVer == null) return null;

    final configs = content['configs'] as Map<String, dynamic>?;
    if (configs == null) return null;

    final config = configs[funcVer] as Map<String, dynamic>?;
    if (config == null) return null;

    final network = config['network'] as Map<String, dynamic>?;
    if (network == null) return null;

    final anUrl = network['an'] as String?;
    if (anUrl == null || anUrl.isEmpty) return null;

    return anUrl;
  } catch (_) {
    return null;
  }
}

/// Parses an announcement HTML page and extracts:
/// - Whether it's image-only (cover type) or has content
/// - The image URL if it's image-only
({String? imageUrl, bool isImageOnly}) _parseAnnouncementHtml(String html) {
  final isImageOnly = html.contains('banner-image-container cover');

  if (isImageOnly) {
    final imgMatch = RegExp(r'<img\s+class="banner-image"\s+src="([^"]+)"').firstMatch(html);
    if (imgMatch != null) {
      return (imageUrl: imgMatch.group(1), isImageOnly: true);
    }
  }

  return (imageUrl: null, isImageOnly: false);
}

/// Process all announcements: fetch HTML and extract images
Future<List<Announcement>> _enrichAnnouncements(
  List<Announcement> announcements,
) async {
  final futures = announcements.map((a) async {
    try {
      final response = await http.get(
        Uri.parse(a.webUrl),
        headers: _defaultHeaders,
      );

      if (response.statusCode != 200) return a;

      final result = _parseAnnouncementHtml(response.body);
      return a.copyWith(
        extractedImageUrl: result.imageUrl,
        isImageOnly: result.isImageOnly,
      );
    } catch (_) {
      return a;
    }
  });

  return Future.wait(futures);
}

Future<AnnouncementMeta?> _fetchAnnouncementMeta(Server server) async {
  final baseUrl = await _fetchAnnouncementBaseUrl(server);
  if (baseUrl == null) return null;

  try {
    final platformUrl = baseUrl.replaceAll('{0}', 'Android');
    final response = await http.get(
      Uri.parse(platformUrl),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    final anBaseUrl = platformUrl.replaceAll(RegExp(r'/announcement\.meta\.json$'), '');
    final meta = AnnouncementMeta.fromJson(data, anBaseUrl: anBaseUrl);

    // Enrich announcements with HTML parsing (extract images)
    final enriched = await _enrichAnnouncements(meta.filteredAnnouncements);

    return AnnouncementMeta(
      announceList: enriched,
      anBaseUrl: anBaseUrl,
    );
  } catch (_) {
    return null;
  }
}

final announcementProvider = FutureProvider<AnnouncementMeta?>((ref) async {
  final hasConnection = ref.watch(effectiveIsConnectedProvider);
  if (!hasConnection) return null;

  final currentServer = ref.watch(configProvider.select((p) => p.currentServer));

  return _fetchAnnouncementMeta(currentServer);
});
