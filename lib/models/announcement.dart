class AnnouncementMeta {
  final List<Announcement> announceList;
  final String? _anBaseUrl;

  const AnnouncementMeta({
    required this.announceList,
    String? anBaseUrl,
  }) : _anBaseUrl = anBaseUrl;

  factory AnnouncementMeta.fromJson(Map<String, dynamic> json, {String? anBaseUrl}) {
    return AnnouncementMeta(
      announceList: (json['announceList'] as List<dynamic>?)
              ?.map((e) => Announcement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      anBaseUrl: anBaseUrl,
    );
  }

  String? get anBaseUrl => _anBaseUrl;

  List<Announcement> get filteredAnnouncements {
    return announceList.where((a) {
      final title = a.title.toLowerCase();
      return !title.contains('fair play');
    }).toList();
  }
}

class Announcement {
  final String announceId;
  final String title;
  final String webUrl;
  final int day;
  final int month;
  final String group;
  final String? extractedImageUrl;
  final bool isImageOnly;

  const Announcement({
    required this.announceId,
    required this.title,
    required this.webUrl,
    required this.day,
    required this.month,
    required this.group,
    this.extractedImageUrl,
    this.isImageOnly = false,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announceId: json['announceId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      webUrl: json['webUrl'] as String? ?? '',
      day: json['day'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      group: json['group'] as String? ?? '',
    );
  }

  Announcement copyWith({
    String? extractedImageUrl,
    bool? isImageOnly,
  }) {
    return Announcement(
      announceId: announceId,
      title: title,
      webUrl: webUrl,
      day: day,
      month: month,
      group: group,
      extractedImageUrl: extractedImageUrl ?? this.extractedImageUrl,
      isImageOnly: isImageOnly ?? this.isImageOnly,
    );
  }

  String? getBannerUrl(String? anBaseUrl) {
    if (extractedImageUrl != null && extractedImageUrl!.isNotEmpty) {
      return extractedImageUrl;
    }
    return null;
  }
}
